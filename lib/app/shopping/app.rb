require "sinatra"

module Shopping
  class App < Sinatra::Base
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
      app(session).query(request, response)
    end

    post "/?*" do
      # LOADER.reload
      app(session).command(request, response)
    end

    def app (session)
      Lucid::App.new(
         {}.tap do |config|
           config[:base_view_class] = BaseView
           config[:handler]         = Actions
           config[:context]         = {
              session: Session.new(session)
           }
           config[:session]         = Session.new(session)
           config[:app_root]        = "/"
         end
      )
    end
  end
end