module Lucid
  class Handler
    include Component::Callbacks
    include Component::Properties

    #
    # Raised when no handler is found for the given command.
    #
    class NoHandlerError < StandardError
      def initialize (command)
        super("No handler for command #{command.class}")
      end
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
    # Instantiate a Handler with a context object. The contact should provide
    # access to the dependencies required by the handler.
    #
    def initialize (handler, context = {})
      @handler = handler
      @context = context
      initialize_props(resolve_dependencies(context))
    end

    def resolve_dependencies (context)
      self.class.props_class.schema.keys.inject({}) do |hash, key|
        hash.merge(
           key.name => context.fetch(key.name) do
             raise MissingDependency.new(self, key.name)
           end
        )
      end
    end

    def call (command)
      instance_exec(command, &@handler)
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
      # Register a handler for the given command class.
      #
      def perform (command_class, &block)
        handlers[command_class] ||= block
      end

      #
      # Returns whether the handler can perform the given command class.
      #
      def performs? (command_class)
        handlers.key?(command_class) ||
           recruits.any? { |r| r.performs?(command_class) }
      end

      #
      # Extend the Handler with the handlers of the given delegate class.
      #
      def recruit (delegate_class)
        recruits << delegate_class
      end

      def dispatch (command, context = {})
        handler, proc = find_handler(command.class)
        raise NoHandlerError.new(command) unless handler
        handler.new(proc, context).call(command)
      end

      #
      # Returns an array containing the matching Handler class and block
      # for the given command class.
      #
      def find_handler (command_class)
        handler = handlers[command_class]
        if handler
          [self, handler]
        else
          delegate = recruits.find { |r| r.performs?(command_class) }
          delegate.find_handler(command_class) if delegate
        end
      end

      def handlers
        @handlers ||= {}
      end

      def recruits
        @recruits ||= []
      end
    end
  end
end