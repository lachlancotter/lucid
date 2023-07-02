require "sinatra/base"
require "awesome_print"
# require "sinatra/reloader"

require "app/ui/link_counter"
require "app/ui/action_counter"

class DemoApp < Sinatra::Base
  configure do
    set :show_exceptions, true
  end

  get "/link_counter/?" do
    LinkCounter.new(params) do |config|
      config.path_root = "/link_counter"
    end.to_s
  end

  get "/action_counter/?" do
    ActionCounter.new(params) do |config|
      config.path_root = "/action_counter"
    end.to_s
  end
end
