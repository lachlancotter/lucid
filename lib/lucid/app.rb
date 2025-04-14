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

    get("/@/?*") { cycle(request, response).link }
    post("/@/?*") { cycle(request, response).command }
    get("/?*") { cycle(request, response).state }

    private

    # ===================================================== #
    #    Build and Dispatch
    # ===================================================== #

    #
    # Build a request/response cycle to dispatch.
    # 
    def cycle (request, response)
      Cycle.new(
         HTTP::RequestAdaptor.new(request), 
         HTTP::ResponseAdaptor.new(response), 
         container
      )
    end

    def container
      settings.container_class.new({
         app_root:        settings.app_root,
         component_class: settings.component_class,
         handler_class:   settings.handler_class,
         session_class:   settings.session_class,
      }, env)
    end

  end
end