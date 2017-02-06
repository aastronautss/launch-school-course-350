require 'mechanize'
require 'csv'

url = ARGV[0]

fail 'You must provide a URL to fetch item data from.' unless url

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

  [detail, product_number, designer]
end

def get_product_info(product, page)
  name = product.css('.productTitle').text.strip
  price = product.css('.regularPrice').text.scan(/\$\d*\.\d*/).first
  image_url = "http://#{page.uri.hostname}#{product.at('img').attr 'src'}"

  detail, product_number, designer = get_detail_info product, page

  [name, detail, product_number, designer, image_url]
end

agent = Mechanize.new
page = agent.get url

title = page.at('h1').text.strip.downcase.gsub ' ', '_'
output_file = "#{title}.csv"
products = page.css '.product'

puts "Loaded #{page.body.length} bytes of #{title} with a status of #{page.code}."

CSV.open output_file, 'w' do |csv|
  products.each { |product| csv << get_product_info(product, page) }
end

