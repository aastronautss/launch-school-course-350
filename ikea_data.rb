require 'mechanize'
require 'csv'

url = ARGV[0]

fail 'You must provide a URL to fetch item data from.' unless url

def format_designer(page_text)
  page_text.gsub(/designers?\s*/i, '').gsub(/\s*\&\s*/, '/')
end

def format_price(price_text)
  begin
    Float price_text.sub(/[^\d\.]/, '')
  rescue ArgumentError => e
    nil
  end
end

def get_detail_info(product, page)
  detail_url = "http://#{page.uri.hostname}#{product.at('.productLink')['href']}"

  detail_agent = Mechanize.new
  detail_page = detail_agent.get detail_url

  detail = detail_page.at('.productType').text.strip
  product_number = detail_page.at('#itemNumber').text.strip
  designer = detail_page.at('#designer').text.strip

  if designer == ''
    alternate_div = detail_page.at('.designerName')
    designer = alternate_div.text.strip if alternate_div
  end

  designer = format_designer(designer)

  [detail, product_number, designer]
end

def get_product_info(product, page)
  name = product.css('.productTitle').text.strip
  price = format_price(product.at('.regularPrice').children.first.text.strip)
  image_url = "http://#{page.uri.hostname}#{product.at('img').attr 'src'}"

  detail, product_number, designer = get_detail_info product, page

  [name, detail, product_number, designer, image_url, price]
end

agent = Mechanize.new
page = agent.get url

title = page.at('h1').text.strip.downcase.gsub ' ', '_'
output_file = "#{title}.csv"
elements = page.css '.product'

puts "Loaded #{page.body.length} bytes of #{title} with a status of #{page.code}."

products = elements.map do |element|
  print '.'
  get_product_info element, page
end

CSV.open output_file, 'w' do |csv|
  products.each { |product| csv << product }
end

puts "\nWrote #{products.count} products to #{output_file}."

