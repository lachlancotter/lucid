module Lucid
  module Eventable
    def self.included (base)
      base.extend(ClassMethods)
    end

    def event_handlers
      self.class.event_handlers || []
    end

    private

    def events_config
      {}
    end

    module ClassMethods
      #
      # Defines a handler function that will respond to
      # notifications with the given class. Block is passed
      # the event instance, and the current view state.
      #
      def on (event_class, &block)
        @event_handlers ||= []
        @event_handlers << EventHandler.new(event_class, &block)
      end

      attr_reader :event_handlers
    end
  end
end