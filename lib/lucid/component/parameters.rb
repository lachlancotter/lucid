module Lucid
  module Component
    module Parameters

      def self.included (base)
        base.extend(ClassMethods)
      end

      def valid?
        state.valid?
      end

      module ClassMethods
        def param (name, options = {})
          @state_class ||= Class.new(State::Base)
          @state_class.attribute(name, options)
          define_method(name) { state.send(name) }
        end

        def validate (&block)
          @state_class ||= Class.new(State::Base)
          @state_class.validate(&block)
        end
      end

    end
  end
end