module Lucid
  module Component
    #
    # Guard conditions for components. Prevents access to the Render object if
    # the guard condition evaluates to Deny so that the component cannot render.
    #
    module Guarded
      def self.included(base)
        base.extend(ClassMethods)
        # base.prepend(RenderOverride)
      end

      def guards
        @guards ||= []
      end

      def denied?
        guards.any?(&:denied?)
      end

      def permitted?
        !denied?
      end

      #
      # Guard condition is still denied after all patrols have been attempted.
      #
      # class MaxPatrolsExceeded < StandardError
      #   def initialize
      #     super("Max patrols exceeded")
      #   end
      # end
      #
      # MAX_PATROLS = 3
      #
      # #
      # # Check all the guard conditions in this component and all subcomponents.
      # # If a guard condition denies access to the component, notify the component
      # # via the Denied event so that components can take action. Then check the
      # # guard conditions again up to the maximum number of patrols.
      # #
      # def check_guards (max = MAX_PATROLS, &block)
      #   max.times do
      #     if_denied { |result| notify Guard::Denied.new(result: result) }
      #     if_permitted { return block.call if block_given? }
      #   end
      #   raise MaxPatrolsExceeded
      # end

      #
      # Call the block if any guard condition in this component or a subcomponent
      # denies access to the component. Always returns nil.
      #
      # def if_denied (&block)
      #   guards.each do |guard|
      #     guard.if_denied { |result| return block.call(result) }
      #   end
      #   subcomponents.values.each do |sub|
      #     Match.on(sub) do
      #       type(Component::Base) do |singleton|
      #         singleton.if_denied { |result| return block.call(result) }
      #       end
      #       type(Enumerable) do |enum|
      #         enum.each { |sub| sub.if_denied { |result| return block.call(result) } }
      #       end
      #     end
      #   end
      #   nil
      # end

      #
      # Call the block if all guard conditions in this component and all subcomponents
      # permit access to the component. Always returns nil.
      #
      def if_permitted (&block)
        block.call if permitted?
        nil
      end

      #
      # DSL methods for defining guard conditions.
      #
      module ClassMethods
        def guard (&block)
          guards << Guard.new(&block)
          after_initialize do
            @guards = self.class.guards.map do |guard|
              guard.bind(self)
            end
          end
        end

        def guards
          @guards ||= []
        end
      end

    end
  end
end