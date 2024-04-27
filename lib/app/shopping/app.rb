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
           config[:base_view_class]     = BaseView
           config[:command_bus_class]   = Actions
           config[:session]             = ShoppingSession.new(session)
           config[:app_root]            = "/"
         end
      )
    end

    class ShoppingSession < Lucid::Session
      attribute(:cart_id) { |id| id || SecureRandom.uuid }
      attribute(:user_email)
      validate do
        required(:cart_id)
        optional(:user_email)
      end
      let(:cart) { |cart_id| Cart.get(cart_id) }
    end

  end
end