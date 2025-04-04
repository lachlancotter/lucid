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
          define_method(name) { fields[name] }
        end

        def props_class
          @props_class ||= if superclass.respond_to?(:props_class)
            Class.new(superclass.props_class)
          else
            Class.new(Dry::Struct)
          end
        end
      end
    end
  end
end