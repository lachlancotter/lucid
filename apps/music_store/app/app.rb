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
      puts "configuring..."
      set :base_view_class, Layout
      set :handler, Handler
      set :session, Session
      set :app_root, "/"
    end

    # def self.build (session)
    #   new(config(session))
    # end

    # def self.config (session)
    #   {
    #      base_view_class: Layout,
    #      handler:         Handler,
    #      context:         {
    #         session: Session.new(session)
    #      },
    #      session:         Session.new(session),
    #      app_root:        "/"
    #   }
    # end
  end
end