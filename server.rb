require "sinatra/base"

$LOAD_PATH.unshift(File.dirname(__FILE__) + "/lib")

require "app/ui/hello"
# require "app/ui/toggle"
# require "app/ui/tabs"
require "app/ui/counter"

class LucidTest < Sinatra::Base
  configure do
    set :show_exceptions, true
  end

  get "/counter" do
    state = { count: params[:count].to_i }
    LinkCounter.new(state).to_s
  end

  get "/:component/:state" do |component, state|
    klass     = Object.const_get(component.capitalize)
    component = klass.new(state.capitalize)
    component.render
  end
end