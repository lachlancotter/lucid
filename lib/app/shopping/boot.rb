require "zeitwerk"

# unless defined?(LOADER)
#   LOADER = Zeitwerk::Loader.new
#   LOADER.push_dir("./lib/app")
#   LOADER.enable_reloading
#   LOADER.setup
# end

require "lucid/app"
require "app/shopping/components/base"
require "app/shopping/actions"

module Shopping
  class App < Sinatra::Base
    configure do
      set :environment, :development
      set :raise_errors, true
      set :show_exceptions, false
      set :public_folder, File.dirname(__FILE__) + "/public"
      set :static, true
    end

    get "/?*" do
      # LOADER.reload
      app.query(request, response)
    end

    post "/?*" do
      # LOADER.reload
      app.command(request, response)
    end

    def app
      Lucid::App.new(app_config)
    end

    # TODO make app Configurable
    def app_config
      {
         base_view_class: Shopping::Base,
         command_bus:     Shopping::Actions.new,
         app_root:        "/"
      }
    end
  end
end