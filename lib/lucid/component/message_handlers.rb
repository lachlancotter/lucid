module Lucid
  module Component
    #
    # Register and call message handlers for a component instance.
    #
    class MessageHandlers
      def initialize
        @handlers = []
      end

      def register (message_filter, *attrs, **map, &block)
        @handlers << Handler.new(message_filter, *attrs, **map, &block)
      end

      def call (message, component)
        @handlers.each do |handler|
          handler.call(message, component)
        end
      end

      class Handler
        def initialize (message_filter, *attrs, **map, &block)
          @message_filter = normalize_message_filter(message_filter)
          @attrs          = attrs
          @map            = map
          @block          = block
        end

        def call (message, component)
          return unless match?(message, component)

          update(component, delta(message))
          component.instance_exec(message, &@block) if @block
        end

        private

        def normalize_message_filter (message_filter)
          case message_filter
          when Constraint then message_filter
          else Types.subclass(Message)[message_filter]
          end
        end

        def match? (message, component)
          case @message_filter
          when Constraint then @message_filter.match?(message, component)
          else message.is_a?(@message_filter)
          end
        end

        def update (component, data)
          component.instance_exec { update(data) } if data.any?
        end

        def delta (message)
          whitelist(message).merge(@map)
        end

        def whitelist (message)
          message.to_h.select { |key, _| @attrs.include?(key) }
        end
      end
    end
  end
end
