module MusicStore
  class App < Lucid::App
    configure do
      # Sinatra configuration
      set :environment, :development
      set :raise_errors, true
      set :show_exceptions, false
      set :public_folder, File.dirname(__FILE__) + "/public"
      set :static, true

      # Lucid configuration
      set :component, Layout
      set :handler, Handler
      set :session, Session
      set :app_root, "/"
    end
  end
end