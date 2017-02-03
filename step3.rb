require 'csv'
require 'json'

source = ARGV[0]

class Library
  def initialize(csv_row)
    @name = csv_row['NAME']
    @hours = Library::Hours.new(csv_row['HOURS OF OPERATION']).to_h
    @address = Library::Address.new(csv_row['ADDRESS'], csv_row['CITY'], csv_row['STATE'], csv_row['ZIP']).to_s
    @coords = Library::Coords.new(csv_row['LOCATION']).to_a
  end

  def to_json(*a)
    {
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: @coords
      },
      properties: {
        name: @name,
        address: @address,
        hours: @hours
      }
    }.to_json(*a)
  end

  class Hours
    def initialize(input_string)
      @input_string = input_string
    end

    def to_h
      output = {}

      groups = @input_string.split /\;\s*/ # / something wrong with text editor syntax highlighting
      groups.each {|group|
        days, hours = group.split /\:\s?/
        next if hours.downcase == 'closed'

        days.split(/\,\s?/).each do |day|
          output[day.downcase.to_sym] = parse_hours(hours)
        end
      }

      output
    end

    private

    def parse_hours(hours)
      hours.split('-').map(&:downcase)
    end
  end

  class Address
    def initialize(address, city, state, zip)
      @address = address
      @city = city
      @state = state
      @zip = zip
    end

    def to_s
      "#{capitalize_all @address}\n#{capitalize_all @city}, #{@state.upcase} #{@zip}"
    end

    private

    def capitalize_all(str)
      str.split.map(&:capitalize).join ' '
    end
  end

  class Coords
    def initialize(input_string)
      @input_string = input_string
    end

    def to_a
      @input_string.gsub(/\(|\)/, '').split(', ').map &:to_f
    end
  end
end

libraries = []

CSV.foreach(source, headers: true) { |row| libraries << Library.new(row) }

data = {
  type: 'FeatureCollection',
  features: libraries
}

puts data.to_json
