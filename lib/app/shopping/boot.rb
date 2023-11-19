require "zeitwerk"

# unless defined?(LOADER)
#   LOADER = Zeitwerk::Loader.new
#   LOADER.push_dir("./lib/app")
#   LOADER.enable_reloading
#   LOADER.setup
# end

require "lucid/app"
require "app/shopping/components/base"

module Shopping
  class App < Sinatra::Base
    configure do
      set :environment, :development
      set :raise_errors, true
      set :show_exceptions, false
      set :public_folder, File.dirname(__FILE__) + "/public"
    end

    get "/?*" do
      # LOADER.reload
      Lucid::App.new(Shopping::Base, "/").query(request)
    end

    post "/?*" do
      # LOADER.reload
      Lucid::App.new(Shopping::Base, "/").command(request)
    end
  end
end