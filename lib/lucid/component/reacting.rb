module Lucid
  module Component
    module Reacting
      def self.included(base)
        base.extend(ClassMethods)
      end

      #
      # Update a value in the state, and trigger invalidation of
      # dependent fields.
      #
      def update (data)
        @state.update(data)
        data.keys.each do |key|
          field(key).invalidate if field?(key)
        end
      end

      def fields
        @fields ||= {}
      end

      def field (name)
        raise Field::NoSuchField.new(name, self) unless field?(name)
        fields[name]
      end

      #
      # Return the nearest ancestor component that defines the specified field.
      #
      def field_in_ancestor (name)
        raise Field::NoSuchField.new(name, self) if props.parent.nil?
        return props.parent.field(name) if props.parent.field?(name)
        props.parent.field_in_ancestor(name)
      end

      def field? (name)
        fields.key?(name)
      end

      module ClassMethods
        #
        # Define a dependent field that is calculated from the specified
        # dependent values. The block is evaluated in the context of the
        # component instance.
        #
        def let (name, &block)
          after_initialize { fields[name] = Field.new(self, &block) }
          define_method(name) { fields[name].value }
        end

        #
        # Declare a dependency on a field defined in a parent component.
        #
        def use (name)
          after_initialize { fields[name] = field_in_ancestor(name) }
          define_method(name) { fields[name].value }
        end

        #
        # Run an arbitrary block of code when a field changes.
        #
        def watch (*keys, &block)
          after_initialize do
            keys.each do |key|
              field(key).attach(self) { instance_exec(&block) }
            end
          end
        end
      end
    end
  end
end