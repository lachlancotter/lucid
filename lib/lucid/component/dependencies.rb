require "dry/struct"

module Lucid
  module Component
    #
    # Container-backed dependencies for components.
    #
    module Dependencies
      def self.included(base)
        base.extend(ClassMethods)
      end

      private

      def validate_dependencies
        self.class.send(:deps_class).schema.keys.each do |key|
          MissingDependency.check(key, self, props.container)
        end
      end

      class MissingDependency < ArgumentError
        def initialize (container, component, name)
          super("#{container.class} is missing dependency `#{name}` required by #{component.class}")
        end

        def self.check (key, component, container)
          unless container.key?(key.name) || key.optional?
            raise new(container, component, key.name)
          end
        end
      end

      module ClassMethods
        #
        # Define a dependency by name and type. Dependencies are resolved from
        # the request container carried by component props.
        #
        def use (name, type)
          dependency_type = Types.normalize(type)
          deps_class.attribute(name, dependency_type)
          key = deps_class.schema.key(name)
          define_method(name) do
            if props.container.key?(name)
              dependency_type[props.container[name]]
            else
              MissingDependency.check(key, self, props.container)
            end
          end
        end

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
