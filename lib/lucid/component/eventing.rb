module Lucid
  module Component
    #
    # Register event handlers that respond to notifications.
    #
    module Eventing
      def self.included (base)
        base.extend(ClassMethods)
      end

      private def apply (event)
        self.class.event_handlers.call(event, self)
        # each_subcomponent { |sub| sub.apply(event) }
      end

      private

      module ClassMethods
        def on (event_type, *keys, **maps, &block)
          with_invalid_event_type_checking(event_type) do
            event_handlers.register(event_type, *keys, **maps, &block)
          end
        end

        def event_handlers
          @event_handlers ||= EventHandlers.new
        end

        def with_invalid_event_type_checking (message_type, &block)
          case message_type
          when Constraint then yield
          when -> (k) { k <= Event } then yield
          when -> (k) { k <= Link }
            raise ApplicationError,
               "Link messages cannot be handled with `on` handlers. Use `to` handlers instead: #{message_type.inspect}"
          else
            raise ArgumentError,
               "Invalid event filter: #{message_type.inspect}"
          end
        end
      end
    end
  end
end