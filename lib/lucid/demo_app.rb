require "sinatra/base"
require "awesome_print"
# require "sinatra/reloader"

# require "app/ui/link_counter"
# require "app/ui/action_counter"
# require "app/ui/multi_counter/view"
require "lucid/controller"

class DemoApp < Sinatra::Base
  configure do
    # set :show_exceptions, true
    set :raise_errors, true
    set :show_exceptions, false
  end

  configure :test do
    set :raise_errors, true
    set :show_exceptions, false
  end

  get "/link_counter/?" do
    LinkCounter.new(params) do |config|
      config.app_root = "/link_counter"
    end.to_s
  end

  %i(get post).each do |method|
    send(method, "/action_counter/?*") do
      Lucid::Controller.new(ActionCounter, "/action_counter").call(params)
    end
  end

  %i(get post).each do |method|
    send(method, "/multi_counter/?*") do
      Lucid::Controller.new(MultiCounter::CounterApp, "/multi_counter").call(params)
    end
  end
end

# MultiCounter::Store.reset!