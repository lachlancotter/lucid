require "dry-struct"

module Lucid
  module Component
    #
    # Define and configure properties for a component.
    #
    module Properties
      def self.included(base)
        base.extend(ClassMethods)
      end

      attr_reader :props

      def initialize_props (props_hash)
        @props = self.class.props_class.new(Check[props_hash].hash.value)
      end

      private

      module ClassMethods
        def prop(name, type = Types.string)
          props_class.attribute(name, type)
          after_initialize { fields[name] = Field.new(self) { props[name] } }
        end

        def props_class
          @props_class ||= Match.on(superclass) do
            responds_to(:props_class) { Class.new(superclass.props_class) }
            default { Class.new(Dry::Struct) }
          end
        end
      end
    end
  end
end