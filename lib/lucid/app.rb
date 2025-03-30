require "sinatra"

module Lucid
  #
  # Top-level interface for dispatching HTTP requests.
  #
  class App < Sinatra::Base
    enable :sessions

    get "/?*" do
      # LOADER.reload
      Logger.cycle(request, response, session) do
        cycle(request, response).query
      end
    end

    post "/?*" do
      # LOADER.reload
      Logger.cycle(request, response, session) do
        cycle(request, response).command
      end
    end

    private

    # def validate (request)
    #   log(request, "Starting validation") do
    #
    #   end
    # end

    def cycle (request, response)
      Cycle.new(
         HTTP::RequestAdaptor.new(request),
         HTTP::ResponseAdaptor.new(response),
         {
            component: settings.component,
            handler:   settings.handler,
            app_root:  settings.app_root,
            session:   settings.session.new(session),
            context:   {
               session: settings.session.new(session),
            }
         }
      )
    end

  end
end