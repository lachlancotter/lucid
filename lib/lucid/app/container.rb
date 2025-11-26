module Lucid
  class App
    #
    # A dependency injection container. Builds, configures and connects
    # the various collaborators of the application.
    # 
    class Container < Injection::Container
      def initialize (config, env)
        super()
        @config = Types.hash[config]
        @env    = Types.hash[env]
      end

      def session_class
        @config[:session_class] || Lucid::App::Session
      end

      def handler_class
        @config[:handler_class] || Lucid::Handler
      end

      def component_class
        @config[:component_class] || Lucid::Component::Base
      end

      provide(:app_root) { @config[:app_root] || "" }
      provide(:csrf_token) { @config[:csrf_token] }
      provide(:request) { HTTP::RequestAdaptor.new(Rack::Request.new(@env), url_base: app_root) }
      provide(:response) { HTTP::ResponseAdaptor.new(Rack::Response.new(@env), url_base: app_root) }
      provide(:session) { session_class.new(@env['rack.session']) }
      provide(:message_bus) { MessageBus.new(handler_class, self) }

      # provide(:component) do
      #   component_class.new(
      #      state,
      #      message,
      #      app_root:  app_root,
      #      container: self,
      #      session:   session
      #   )
      # end
      
      # provide(:message) do
      #   message = nil
      #   request.yield_link { |link| message = link } if request&.has_message?
      #   message || message_bus.published.first
      # end

      # provide(:state) { request.state_reader }
    end
  end
end