module Lucid
  #
  # Base class for message handlers. Provides a class level DSL for defining
  # message handler blocks, and handler dependencies. Messages are dispatched
  # to the class object. If a matching handler is found, the Handler class is
  # instantiated with that handler block and the message is passed to it.
  # 
  # noinspection RubyResolve
  class Handler
    include Component::Callbacks
    include Injection::Consumer
    extend CommandDispatch
    extend EventBroadcast

    #
    # The message bus is shared among all handlers. This provides a means for
    # handlers to dispatch commands and publish events for other handlers.
    # 
    use :message_bus, Types.instance(MessageBus)

    #
    # Handlers have access to the session object, which is a wrapper around
    # the Rack session. This allows handlers to store and retrieve data
    # from the session.
    # 
    use :session, Types.instance(App::Session)

    #
    # Instantiate a Handler with a container object and code block.
    # The block will be called with the message as an argument.
    # The container provides the dependencies required by the handler.
    #
    def initialize (container, &handler)
      super(container)
      @handler = handler
    end

    #
    # Entry point for handlers.
    # 
    def call (message)
      instance_exec(message, &@handler)
    end

    #
    # Publish new events for other handlers and components to consume.
    # 
    def publish (event)
      message_bus.publish(event)
    end

    #
    # Dispatch new commands to other handlers.
    # 
    def dispatch (command)
      message_bus.dispatch(command)
    end

    #
    # DSL methods.
    #
    class << self
      def recruit (message_class)
        recruit_dispatcher message_class
        recruit_broadcaster message_class
      end
    end
  end
end