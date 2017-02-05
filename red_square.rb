require 'chunky_png'

png = ChunkyPNG::Image.new 256, 256, ChunkyPNG::Color.from_hex('#ff0000')
png.save 'red_square.png', interlace: true

# Or...

png = ChunkyPNG::Image.new 256, 256
color = ChunkyPNG::Color.from_hex '#ff0000' # or...
color = ChunkyPNG::Color.rgb 255, 0, 0

256.times do |x|
  256.times do |y|
    png[x, y] = color
  end
end

png.save 'red_square.png', interlace: true
