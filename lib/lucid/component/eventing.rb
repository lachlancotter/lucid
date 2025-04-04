module Lucid
  module Component
    #
    # Register event handlers that respond to notifications.
    #
    module Eventing
      def self.included (base)
        base.extend(ClassMethods)
      end
      
      def notify (event)
        self.class.event_handlers.notify(event, self)
        each_subcomponent { |sub| sub.notify(event) }
      end

      private

      module ClassMethods
        def on (event_type, *keys, **maps, &block)
          event_handlers.register(event_type, *keys, **maps, &block)
        end

        def event_handlers
          @responders ||= EventHandlers.new
        end
      end
    end
  end
end