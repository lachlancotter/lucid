require "sinatra/base"
require "awesome_print"
# require "sinatra/reloader"

require "app/ui/link_counter"
require "app/ui/action_counter"
require "lucid/controller"

class DemoApp < Sinatra::Base
  configure do
    set :show_exceptions, true
  end

  get "/link_counter/?" do
    LinkCounter.new(params) do |config|
      config.app_root = "/link_counter"
    end.to_s
  end

  %i(get post).each do |method|
    send(method, "/action_counter/?*") do
      controller = Lucid::Controller.new(ActionCounter, "/action_counter")
      controller.call(params)
    end
  end
end