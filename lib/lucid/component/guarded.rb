module Lucid
  module Component
    #
    # Guard conditions for components. Prevents access to the Render object if
    # the guard condition evaluates to Deny so that the component cannot render.
    #
    module Guarded
      def self.included(base)
        base.extend(ClassMethods)
        base.prepend(RenderOverride)
      end

      def denied?
        if_denied { return true }
        false
      end

      def permitted?
        !denied?
      end

      #
      # Wrap the render method to guard access to the component.
      #
      module RenderOverride
        def render
          if_denied { |guard| raise Guard::Violation.new(guard) }
          if_permitted { return super }
        end
      end

      #
      # Guard condition is still denied after all patrols have been attempted.
      #
      class MaxPatrolsExceeded < StandardError
        def initialize
          super("Max patrols exceeded")
        end
      end

      MAX_PATROLS = 3

      #
      # Check all the guard conditions in this component and all subcomponents.
      # If a guard condition denies access to the component, notify the component
      # via the Denied event so that components can take action. Then check the
      # guard conditions again up to the maximum number of patrols.
      #
      def patrol (max = MAX_PATROLS)
        max.times do
          if_denied { |result| notify Guard::Denied.new(result: result) }
          if_permitted { return Permit }
        end
        raise MaxPatrolsExceeded
      end

      #
      # Call the block if any guard condition in this component or a subcomponent
      # denies access to the component. Always returns nil.
      #
      def if_denied (&block)
        nil.tap do
          self.class.guard_conditions.each do |guard|
            guard.bind(self).if_denied { |result| return block.call(result) }
          end
          subcomponents.values.each do |sub|
            sub.if_denied { |result| return block.call(result) }
          end
        end
      end

      #
      # Call the block if all guard conditions in this component and all subcomponents
      # permit access to the component. Always returns nil.
      #
      def if_permitted (&block)
        nil.tap do
          block.call if permitted?
        end
      end

      #
      # DSL methods for defining guard conditions.
      #
      module ClassMethods
        def guard (&block)
          guard_conditions << Guard.new(&block)
        end

        def guard_conditions
          @guard_conditions ||= []
        end
      end

    end
  end
end