module Lucid
  #
  # Base class for events.
  #
  class Event
    class << self
      #
      # Configure the event bus that will be used to notify the
      # application of events.
      #
      attr_accessor :bus

      #
      # Define the event data.
      #
      def params (&block)
        @params_class = Class.new(State, &block)
      end

      def params_class
        @params_class ||= Class.new(State)
      end

      def notify (data)
        new(data).notify
      end
    end

    def initialize (data)
      @data = self.class.params_class.new(data)
    end

    attr_reader :data

    def notify
      Event.bus.notify(self)
    end
  end
end