module Lucid
  #
  # Base class for message handlers. Provides a class level DSL for defining
  # message handler blocks, and handler dependencies. Messages are dispatched
  # to the class object. If a matching handler is found, the Handler class is
  # instantiated with that handler block and the message is passed to it.
  # 
  class Handler
    include Component::Callbacks
    include Component::Properties
    extend CommandDispatch
    extend EventBroadcast

    #
    # The message bus is shared among all handlers. This provides a means for
    # handlers to dispatch commands and publish events for other handlers.
    # 
    prop :bus, Types.Instance(Class).optional
    
    #
    # Instantiate a Handler with a container object and code block.
    # The block will be called with the message as an argument.
    # The container provides the dependencies required by the handler.
    #
    def initialize (container = {}, &handler)
      @handler   = handler
      @container = container
      initialize_props(
         self.class.resolve_dependencies(container)
      )
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
      bus.publish(event, @container)
    end

    #
    # Dispatch new commands to other handlers.
    # 
    def dispatch (command)
      bus.dispatch(command, @container)
    end

    #
    # Raised when attempting to construct a Handler instance without
    # the required dependencies.
    #
    class MissingDependency < ArgumentError
      def initialize (handler, name)
        super("Missing dependency `#{name}` for #{handler.class}")
      end
    end

    #
    # DSL methods.
    #
    class << self
      #
      # Declare a dependency for the handler.
      #
      def prop (name, type = Types.string)
        props_class.attribute(name, type)
        define_method(name) { props[name] }
      end

      #
      # Builds a hash of dependencies for the handler from the provided
      # container object. This enables us to accept containers with missing
      # dependency keys, provided those dependencies are optional.
      # 
      def resolve_dependencies (container)
        {}.tap do |hash|
          props_class.schema.keys.each do |key|
            hash[key.name] = container.fetch(key.name) do
              unless key.optional?
                raise MissingDependency.new(self, key.name)
              end
            end
          end
        end
      end
      
    end
  end
end