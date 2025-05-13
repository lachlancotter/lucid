module Lucid
  module Component
    #
    # Provides guard expressions for components. Guards are conditions that must
    # be met in order for the component to render. If the guard condition is not
    # met, the component will return a special DENIED_TEMPLATE instead of the
    # normal template.
    # 
    # You can override the DENIED_TEMPLATE content by defining a template with the same
    # name in your component.
    #
    module Guarded
      def self.included(base)
        base.extend(ClassMethods)
        base.prepend(TemplateOverride)
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

      module TemplateOverride
        def template (name = Rendering::BASE_TEMPLATE)
          if denied?
            self.class.template(PermissionError).bind(self)
          else
            super
          end
        end
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
          if guards.length == 1
            # Register the callback exactly once regardless of how many guards are defined.
            after_build do
              raise PermissionError.new(self) if denied?
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