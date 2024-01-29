require "lucid/state/base"

module Lucid
  module Component
    #
    # Stateful components contain a state object which can define
    # defaults and validation rules.
    #
    module Stateful
      def self.included (base)
        base.extend(ClassMethods)
      end

      # def encode_state
      #   JSON.encode(@state.to_h)
      # end

      attr_reader :state

      def valid?
        state.valid?
      end

      module ClassMethods
        #
        # Defines the state attributes and validation rules
        # for this Stateful component class.
        #
        def state (&block)
          @state_class = Class.new(State::Base, &block)
        end

        #
        # Access the state class. Provides a default if none
        # has been defined.
        #
        def state_class
          @state_class ||= Class.new(State::Base)
        end

        #
        # Instantiate a state object from the given data.
        #
        def build_state (data)
          # Exclude keys that belong to nested components.
          state_class.new(data.reject { |k, v| nests.keys.include?(k) })
        end

        def normalize_state (state)
          if state.is_a?(Hash)
            build_state(state)
          elsif state.is_a?(state_class)
            state
          else
            raise ArgumentError, "Expected #{state_class}, got #{state.class}"
          end
        end

      end
    end
  end
end