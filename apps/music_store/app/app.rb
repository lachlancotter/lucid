module MusicStore
  class App < Lucid::App
    configure do
      # Sinatra configuration
      set :environment, :development
      set :raise_errors, true
      set :show_exceptions, false
      set :public_folder, File.dirname(__FILE__) + "/../public"
      set :static, true

      # Lucid configuration
      set :component_class, Layout
      set :handler_class, Handler
      set :session_class, Session
      set :container_class, Container
      set :app_root, "/"
    end
  end
end