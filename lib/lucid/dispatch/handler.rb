module Lucid
  class Handler
    include Component::Callbacks
    include Component::Properties
    extend CommandDispatch

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
    def initialize (context = {}, &handler)
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
    end
  end
end