require "dry/struct"

module Lucid
  module Injection
    #
    # A consumer of dependency injection. Define dependencies with the
    # `use` method. Provide a container object to the constructor. The container
    # is used to resolve the dependencies.
    # 
    module Consumer

      def self.included(base)
        base.extend(ClassMethods)
      end

      def initialize (container)
        @container = validate_dependencies(container)
      end

      private

      #
      # Check that the container has keys for each dependency.
      # 
      def validate_dependencies (container)
        container.tap do
          deps_schema.keys.each do |key|
            MissingDependency.check(key, self, container)
          end
        end
      end

      private

      def deps_schema
        self.class.send(:deps_class).schema
      end

      #
      # Raised when attempting to construct an instance without
      # the required dependencies.
      #
      class MissingDependency < ArgumentError
        def initialize (container, consumer, name)
          super("#{container.class} is missing dependency `#{name}` required by #{consumer.class}")
        end

        def self.check (key, consumer, container)
          unless container.key?(key.name) || key.optional?
            raise new(container, consumer, key.name)
          end
        end
      end

      module ClassMethods
        #
        # Define a dependency by name and type. The type is used to validate the 
        # dependency when it is resolved. The type must be a Dry::Types.
        # 
        def use (name, type)
          deps_class.attribute(name, Types.normalize(type))
          key = deps_class.schema.key(name)
          define_method(name) do
            if @container.key?(name)
              @container[name]
            else
              # Raise an error unless the dependency is optional.
              MissingDependency.check(key, self, @container)
            end
          end
        end

        #
        # We build a Dry::Struct to use as a schema for the required dependencies.
        # This is just a convenient way of mapping names to types. We don't actually
        # instantiate the struct.
        #
        def deps_class
          @deps_class ||= if superclass.respond_to?(:deps_class)
            Class.new(superclass.deps_class)
          else
            Class.new(Dry::Struct)
          end
        end
      end

    end
  end
end