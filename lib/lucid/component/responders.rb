module Lucid
  module Component
    #
    # Register and call event handlers for a component class.
    # 
    class Responders
      def initialize
        @responders = []
      end

      def register (message_type, *keys, **maps, &block)
        @responders << Constrained.new(
           normalize_constraint(message_type, *keys, **maps), &block
        )
      end

      def notify (message, context = {})
        @responders.each do |responder|
          responder.call(message, context)
        end
      end

      private

      def normalize_constraint (type, *keys, **maps, &block)
        case type
        when Constraint
          type
        when -> (k) { k <= Event }
          Constraint.new(type, *keys, **maps, &block)
        else
          raise ArgumentError, "Invalid message filter: #{type.inspect}"
        end
      end

      #
      # Delegates to the block only if the constraint is satisfied.
      #
      class Constrained
        def initialize (constraint, &block)
          @constraint = Types.Instance(Constraint)[constraint]
          @block      = Types.Instance(Proc)[block]
        end

        def call (message, context = {})
          context.instance_exec(message, &@block) if @constraint.match?(message, context)
        end
      end

    end
  end
end