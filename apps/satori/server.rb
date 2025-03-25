require "sinatra"

module Satori
  class Server < Sinatra::Base
    enable :sessions

    configure do
      set :environment, :development
      set :raise_errors, true
      set :show_exceptions, false
      set :public_folder, File.dirname(__FILE__) + "/public"
      set :static, true
    end

    get "/?*" do
      # LOADER.reload
      App.build(session).query(request, response)
    end

    post "/?*" do
      # LOADER.reload
      App.build(session).command(request, response)
    end
  end
end