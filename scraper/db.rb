require "sequel"

DB = Sequel.connect('sqlite://scraper.sqlite3')

module Database
  def self.create_tables
    DB.create_table :items do
      String :series
      String :description
      String :number, primary_key: true
      String :designer
      String :image_url
      Float :price
    end
  end
end
