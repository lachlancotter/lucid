module Lucid
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
        state_class.new(data)
      end
    end
  end
end