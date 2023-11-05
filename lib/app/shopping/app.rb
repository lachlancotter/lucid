require "zeitwerk"

# unless defined?(LOADER)
#   LOADER = Zeitwerk::Loader.new
#   LOADER.push_dir("./lib/app")
#   LOADER.enable_reloading
#   LOADER.setup
# end

require "lucid/controller"
require "app/shopping/components/base"

module Shopping
  class App < Sinatra::Base
    configure do
      set :environment, :development
      set :raise_errors, true
      set :show_exceptions, false
      set :public_folder, File.dirname(__FILE__) + "/public"
    end

    %i(get post).each do |method|
      send(method, "/?*") do
        # LOADER.reload
        Lucid::Controller.new(Shopping::Base, "/").call(request.fullpath, params)
      end
    end
  end
end