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

      provide(:app_root) { @config[:app_root] || "/" }
      
      provide(:request) do
        HTTP::RequestAdaptor.new(Rack::Request.new(@env), url_base: app_root)
      end

      provide(:response) do
        HTTP::ResponseAdaptor.new(Rack::Response.new(@env), url_base: app_root)
      end

      provide(:session) do
        session_class.new(@env['rack.session'])
      end

      provide(:message_bus) do
        MessageBus.new(component, handler_class, self)
      end

      provide(:component) do
        component_class.new(state,
           app_root:  app_root,
           container: self,
           session:   session,
           path:      Path.new
        )
      end

      provide(:state) { request.state_reader }
    end
  end
end