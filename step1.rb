require 'csv'
require 'json'

source = ARGV[0]

class LibraryHours
  def initialize(input_string)
    @input_string = input_string
  end

  def to_h
    output = {}

    groups = @input_string.split /\;\s*/ # / something wrong with text editor syntax highlighting
    groups.each do |group|
      days, hours = group.split /\:\s?/
      next if hours.downcase == 'closed'

      days.split(/\,\s?/).each do |day|
        output[day.downcase.to_sym] = parse_hours(hours)
      end
    end

    output
  end

  private

  def parse_hours(hours)
    hours.split('-').map(&:downcase)
  end
end

class LibraryAddress
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

class LibraryCoords
  def initialize(input_string)
    @input_string = input_string
  end

  def to_a
    @input_string.gsub(/\(|\)/, '').split(', ').map &:to_f
  end
end

CSV.foreach source, headers: true do |row|
  library_name = row['NAME']
  hours = LibraryHours.new(row['HOURS OF OPERATION']).to_h
  address = LibraryAddress.new(row['ADDRESS'], row['CITY'], row['STATE'], row['ZIP']).to_s
  coords = LibraryCoords.new(row['LOCATION']).to_a

  formatted_row = [library_name, address, hours, coords]
  p formatted_row
end
