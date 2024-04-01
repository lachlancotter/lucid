module Lucid
  module Component
    module Responding
      def self.included (base)
        base.extend(ClassMethods)
      end

      def notify (event)
        handler = self.class.event_handler(event.class)
        instance_exec(event, &handler) if handler.is_a?(Proc)
        nests.values.each { |nest| nest.notify(event) }
      end

      private

      module ClassMethods
        #
        # Defines a handler function that will respond to
        # notifications with the given class. Block is passed
        # the event instance, and the current view state.
        #
        def on (event_class, &block)
          @event_handlers              ||= {}
          @event_handlers[event_class] = block
          # << EventHandler.new(event_class, &block)
        end

        def event_handler (event_class)
          (@event_handlers || {})[event_class]
        end
      end
    end
  end
end