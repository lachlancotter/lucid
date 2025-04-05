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
      
      def to_s
        "<#{self.class.name} {#{self.class.keys}}>"
      end
      
      def inspect
        to_s
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

      def app_root
        @config[:app_root] || "/"
      end

      provide(:request) do
        HTTP::RequestAdaptor.new(Rack::Request.new(@env))
      end

      provide(:response) do
        HTTP::ResponseAdaptor.new(Rack::Response.new(@env))
      end

      provide(:session) do
        session_class.new(@env['rack.session'])
      end

      provide(:message_bus) do
        MessageBus.new(component, handler_class, self)
      end

      provide(:component) do
        component_class.new(state, app_root: app_root, session: session, path: Path.new)
      end

      provide(:state) do
        request.state_reader(app_root: app_root)
      end

      #
      # Dispatch events to the component and handler.
      # 
      class MessageBus
        def initialize (component, handler, container)
          @component = Types.component[component]
          @handler   = Types.handler[handler]
          @container = Types.container[container]
        end

        def dispatch (command)
          @handler.dispatch(command, @container)
        end

        def publish (event)
          @handler.publish(event, @container)
          @component.notify(event)
        end
        
        def to_s
          "<#{self.class.name} #{object_id}>"
        end
        
        def inspect
          to_s
        end
      end

    end
  end
end