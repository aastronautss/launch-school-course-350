require 'chunky_png'

png = ChunkyPNG::Image.new 256, 256

255.times do |x|
  255.times do |y|
    color = ChunkyPNG::Color.rgb(255 - x, x, y)
    png[x, y] = color
  end
end

png.save 'gradient_square.png', interlace: true
