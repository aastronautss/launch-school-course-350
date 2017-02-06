require "sinatra/base"
require "tilt/erubis"
require "sinatra/reloader"

require_relative "./db"

class Web < Sinatra::Application
  configure :development do
    register Sinatra::Reloader
    set :views, "views"
    set :port, 5000
  end

  get "/" do
    @items = DB[:items].all
    erb :index, layout: :application
  end

  get "/designers" do
    @designers = DB[:items].
      select_group{ designer.as(name) }.
      select_append{ count(series).as(items_count) }.
      select_append{ avg(price).as(average_price) }.
      all
    erb :designers, layout: :application
  end

  run! if __FILE__ == $PROGRAM_NAME
end
