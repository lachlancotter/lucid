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

      private

      def configure (&block)
        props_hash = block_given? ? Check[block.call].hash.value : {}
        @props = self.class.props_class.new(props_hash)
      end

      module ClassMethods
        def prop(name, default: nil, &constructor)
          props_class.attribute(name, default: default, &constructor)
        end

        def props_class
          @props_class ||= Match.on(superclass) do
            responds_to(:props_class) { Class.new(superclass.props_class) }
            default { Class.new(State::Base) }
          end
        end
      end
    end
  end
end