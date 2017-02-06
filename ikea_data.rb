require 'mechanize'

url = ARGV[0]

fail 'You must provide a URL to fetch item data from.' unless url

def get_additional_info(product, page)
  detail_url = "http://#{page.uri.hostname}#{product.at('a').attr 'href'}"

  detail_agent = Mechanize.new
  detail_page = detail_agent.get detail_url

  detail = detail_page.at('.productType').text.strip
  product_number = detail_page.at('#itemNumber').text.strip
  designer = detail_page.at('#designer').text.strip

  [detail, product_number, designer]
end

def print_product(product, page)
  name = product.css('.productTitle').text.strip
  description = product.css('.productDesp').text.capitalize
  price = product.css('.regularPrice').text.scan(/\$\d*\.\d*/).first
  image_url = "http://#{page.uri.hostname}#{product.at('img').attr 'src'}"

  detail, product_number, designer = get_additional_info product, page

  puts "#{name} #{description}, #{detail} (#{product_number}) by #{designer}: #{price}\n#{image_url}"
end

agent = Mechanize.new
page = agent.get url

title = page.at('h1').text
products = page.css '.product'

puts "Loaded #{page.body.length} bytes of #{title} with a status of #{page.code}."

products.each { |product| print_product product, page }
