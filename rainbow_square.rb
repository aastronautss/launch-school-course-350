require 'chunky_png'

COLORS = ['red', 'orange', 'yellow', 'yellowgreen', 'green', 'blue', 'indigo', 'purple', 'violet'].freeze

png = ChunkyPNG::Image.new 252, 252

251.times do |x|
  251.times do |y|
    column = x / 28
    color = ChunkyPNG::Color COLORS[column]
    png[x, y] = color
  end
end

png.save 'rainbow_square.png', interlace: true
