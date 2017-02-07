require 'csv'
require 'date'
require 'ostruct'
require 'mustache'
require 'pdfkit'
require 'fileutils'

FileUtils.mkdir_p 'notices'

def pluralize(string, quantity)
  string += "s" if quantity != 1
  format("%d %s", quantity, string)
end

def format_cence(int)
  format("$%.2f", cents / 100.0)
end

FINE_PER_DAY = 20

data_path = 'data'
checkouts_path = File.join data_path, 'checkouts.csv'
books_path = File.join data_path, 'books.csv'
users_path = File.join data_path, 'users.csv'

today = Date.new 2015, 6, 15

books = CSV.read books_path, headers: true
users = CSV.read users_path, headers: true
checkouts = CSV.read checkouts_path, headers: true, converters: :date

overdue_checkouts = checkouts.select do |checkout|
  checkout['due'] <= today - 1
end

users_with_overdue_checkouts = overdue_checkouts.map do |checkout|
  checkout['user_id']
end

checkouts_by_user = overdue_checkouts.group_by { |row| row['user_id'] }.to_a

user_id, user_checkouts = checkouts_by_user[3]

checkouts_by_user.each do |user_id, user_checkouts|
  print '.'

  user = OpenStruct.new(users.find { |u| u['id'] == user_id }.to_h)

  user_books = user_checkouts.map do |checkout|
    book_hash = books.find { |b| b['id'] == checkout['book_id'] }.to_h
    book_hash['due'] = checkout['due']
    book_hash['days_late'] = Integer(today - checkout['due'])
    book_hash['total_fine'] = Integer(book_hash['days_late'] * FINE_PER_DAY)
    book_hash['formatted_daily_fine'] = format_cents FINE_PER_DAY
    book_hash['formatted_total_fine'] = format_cents book_hash['total_fine']

    OpenStruct.new book_hash
  end

  total_fine = books.map(&:total_fine).inject :+

  context = {
    user: user,
    books: user_books,
    overdue_books_count: pluralize('overdue book', user_books.size),
    formatted_total_fone: format_cents(total_fine)
  }
  template = File.read 'template/template.mustache'

  html = Mustache.render template, context
  pdf = PDFKit.new html, page_size: 'Letter'

  pdf.stylesheets << 'template/css/bootstrap.css'
  pdf.stylesheets << 'template/css/notice.css'

  pdf.to_file "notices/#{user.username}.pdf"
end

puts ''
puts 'Notices created!'
