module Lucid
  module Component
    #
    # Register and call event handlers for a component class.
    # 
    class EventHandlers
      def initialize
        @handlers = []
      end

      def register (message_type, *keys, **maps, &block)
        @handlers << Constrained.new(
           normalize_constraint(message_type, *keys, **maps), &block
        )
      end

      def call (event, container = {})
        @handlers.each do |handler|
          handler.call(event, container)
        end
      end

      private

      def normalize_constraint (type, *keys, **maps, &block)
        case type
        when Constraint then type
        when -> (k) { k <= Event } then Constraint.new(type, *keys, **maps, &block)
        else raise ArgumentError, "Invalid message filter: #{type.inspect}"
        end
      end

      #
      # Delegates to the block only if the constraint is satisfied.
      #
      class Constrained
        def initialize (constraint, &block)
          @constraint = Types.instance(Constraint)[constraint]
          @block      = Types.instance(Proc)[block]
        end

        def call (message, context = {})
          context.instance_exec(message, &@block) if @constraint.match?(message, context)
        end
      end

    end
  end
end