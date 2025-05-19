module Lucid
  module Component
    #
    # Register event handlers that respond to notifications.
    #
    module Eventing
      def self.included (base)
        base.extend(ClassMethods)
      end

      def apply (event)
        self.class.event_handlers.call(event, self)
        each_subcomponent { |sub| sub.apply(event) }
      end

      private

      module ClassMethods
        def on (event_type, *keys, **maps, &block)
          event_handlers.register(event_type, *keys, **maps, &block)
        end

        def event_handlers
          @event_handlers ||= EventHandlers.new
        end
      end
    end
  end
end