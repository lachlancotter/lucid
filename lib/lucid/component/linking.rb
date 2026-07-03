module Lucid
  module Component
    module Linking
      #
      # Apply the block for the given link type to the current
      # state, and return the transformed state. Used to resolve the
      # href for global links.
      #
      private def handle_link (link)
        Types.instance(Link)[link]
        message_handlers.call(link, self)
      end

      def self.included (base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        #
        # Defines the state the component needs to be in to answer
        # the given query. The block is passed the query instance
        # and a copy of the current view state. The block should
        # mutate the state to reflect the query.
        #
        # Returns the route to the view state that answers the query.
        #
        # link_filter may be a Link subclass or constrained Link type.
        #
        def to (link_filter, *attrs, **map, &block)
          with_invalid_link_type_checking(link_filter) do
            after_initialize do
              message_handlers.register(link_filter, *attrs, **map, &block)
            end
          end
        end

        def with_invalid_link_type_checking (message_filter, &block)
          case message_filter
          when -> (f) { f.is_a?(Constraint) && f.message_class <= Link } then yield
          when -> (f) { f.is_a?(Constraint) && f.message_class <= Event }
            raise ApplicationError,
               "Event messages cannot be handled with `to` handlers. Use `on` handlers instead: #{message_filter.inspect}"
          when -> (k) { k.is_a?(Class) && k <= Link } then yield
          when -> (k) { k.is_a?(Class) && k <= Event }
            raise ApplicationError,
               "Event messages cannot be handled with `to` handlers. Use `on` handlers instead: #{message_filter.inspect}"
          else
            raise ArgumentError,
               "Invalid link filter: #{message_filter.inspect}"
          end
        end

      end
    end
  end
end
