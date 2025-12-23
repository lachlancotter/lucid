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

      attr_reader :config, :env

      def session_class
        @config[:session_class] || Lucid::App::Session
      end

      def handler_class
        @config[:handler_class] || Lucid::Handler
      end

      def component_class
        @config[:component_class] || Lucid::Component::Base
      end

      def base_request
        @config[:request] || Rack::Request.new(@env)
      end

      def base_response
        @config[:response] || Rack::Response.new(@env)
      end

      provide(:app_root) { @config[:app_root] || "" }
      provide(:csrf_token) { @config[:csrf_token] }
      provide(:request) { HTTP::RequestAdaptor.new(base_request, url_base: app_root) }
      provide(:response) { HTTP::ResponseAdaptor.new(base_response, url_base: app_root) }
      provide(:session) { session_class.new(@env['rack.session']) }
      provide(:message_bus) { MessageBus.new(handler_class, self) }
    end
  end
end