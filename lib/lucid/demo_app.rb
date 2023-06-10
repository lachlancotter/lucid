require "sinatra/base"
require "awesome_print"
# require "sinatra/reloader"

require "app/ui/counter"


class DemoApp < Sinatra::Base
  configure do
    set :show_exceptions, true
  end

  # configure :development do
  #   register Sinatra::Reloader
  #   also_reload "*.rb"
  # end

  get "/counter/?" do
    state = { count: params[:count].to_i }
    LinkCounter.new(state) do |config|
      config.path_root = "/counter"
    end.to_s
  end

  # get "/:component/:state" do |component, state|
  #   klass     = Object.const_get(component.capitalize)
  #   component = klass.new(state.capitalize)
  #   component.render
  # end
end
