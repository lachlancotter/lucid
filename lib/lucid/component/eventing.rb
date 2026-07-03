module Lucid
  module Component
    #
    # Register event handlers that respond to notifications.
    #
    module Eventing
      def self.included (base)
        base.extend(ClassMethods)
      end

      private def handle_event (event)
        Types.instance(Event)[event]
        message_handlers.call(event, self)
      end

      private

      module ClassMethods
        def on (event_filter, *attrs, **map, &block)
          with_invalid_event_type_checking(event_filter) do
            after_initialize do
              message_handlers.register(event_filter, *attrs, **map, &block)
            end
          end
        end

        def with_invalid_event_type_checking (message_filter, &block)
          case message_filter
          when -> (f) { f.is_a?(Constraint) && f.message_class <= Event } then yield
          when -> (f) { f.is_a?(Constraint) && f.message_class <= Link }
            raise ApplicationError,
               "Link messages cannot be handled with `on` handlers. Use `to` handlers instead: #{message_filter.inspect}"
          when -> (k) { k.is_a?(Class) && k <= Event } then yield
          when -> (k) { k.is_a?(Class) && k <= Link }
            raise ApplicationError,
               "Link messages cannot be handled with `on` handlers. Use `to` handlers instead: #{message_filter.inspect}"
          else
            raise ArgumentError,
               "Invalid event filter: #{message_filter.inspect}"
          end
        end
      end
    end
  end
end
