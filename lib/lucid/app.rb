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

    get("/@/?*") { Cycle.new(container(request, response)).link }
    post("/@/?*") { Cycle.new(container(request, response)).command }
    get("/?*") { Cycle.new(container(request, response)).state }

    private

    # ===================================================== #
    #    Build and Dispatch
    # ===================================================== #

    def container (request, response)
      settings.container_class.new({
         app_root:        settings.app_root,
         component_class: settings.component_class,
         handler_class:   settings.handler_class,
         session_class:   settings.session_class,
         request:         request,
         response:        response
      }, env)
    end

  end
end