module Lucid
  module Component
    module Temps
      def self.included(base)
        base.extend ClassMethods
      end

      def touch (hash)
        hash.each do |key, value|
          instance_variable_set("@#{key}", value)
          invalidate key
        end
      end

      module ClassMethods
        #
        # Define a signal based on a temporary value stored in an instance variable.
        # Useful for lazy loading or flash-like values that don't need to be persisted
        # in the component state.
        # 
        def temp (name, type = Types.string.optional.default(nil))
          after_initialize do
            instance_variable_set("@#{name}", type[])
            fields[name] = Field.new(self) { instance_variable_get("@#{name}") }
          end
          define_method(name) { fields[name].value }
        end
      end
    end
  end
end