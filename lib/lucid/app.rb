require "sinatra"
require "dry-configurable"

module Lucid
  #
  # Top-level interface for dispatching HTTP requests.
  #
  class App < Sinatra::Base
    enable :sessions

    # include Dry::Configurable
    
    # ===================================================== #
    #    Default Settings
    # ===================================================== #
    
    # The root component class.
    set :component_class, lambda { raise "Component class not set" }

    # The root handler class.
    set :handler_class, Lucid::Handler

    # The container object for resolving dependencies.
    set :container_class, Lucid::App::Container

    # The session class for wrapping the Rack session.
    set :session_class, Lucid::App::Session

    # Web root path, prepended to all URLs.
    set :app_root, "/"

    # ===================================================== #
    #    Routing
    # ===================================================== #
    
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
    
    # ===================================================== #
    #    Build and Dispatch
    # ===================================================== #
    

    # def validate (request)
    #   log(request, "Starting validation") do
    #
    #   end
    # end

    #
    # Build a request/response cycle to dispatch.
    # 
    def cycle (request, response)
      Cycle.new(
         HTTP::RequestAdaptor.new(request),
         HTTP::ResponseAdaptor.new(response),
         component_class: settings.component_class,
         handler_class:   settings.handler_class,
         container:       container,
         app_root:        settings.app_root
      )
    end

    #
    # Build the container object for resolving dependencies within
    # a request/response cycle.
    # 
    def container
      settings.container_class.new(settings, session)
    end

  end
end