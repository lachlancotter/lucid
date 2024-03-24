module Lucid
  module Component
    module Dataflow
      def self.included(base)
        base.extend(ClassMethods)
      end

      #
      # Update a value in the state, and trigger invalidation of
      # dependent fields.
      #
      def update (data)
        @state.update(data)
        data.keys.map { |key| field(key) }.each(&:notify)
      end

      def fields
        @fields ||= {}
      end

      def field (name)
        fields[name]
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
          after_initialize { fields[name] = Field.new(self, name, &block) }
          define_method(name) { fields[name].value }
        end

        #
        # Declare a dependency on a field defined in a parent component.
        #
        def use (name)
          define_method(name) do
            current = config.parent
            while current
              if current.field?(name)
                return current.send(name)
              else
                current = current.config.parent
              end
            end
            raise Field::NoSuchField.new(name)
          end
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