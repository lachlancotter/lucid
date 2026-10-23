module Lucid
  module Component
    module Title
      def self.included (base)
        base.extend(ClassMethods)
        base.let(:nested_title) { nested_route_component.title }
        base.title { "Untitled" }

        base.after_build do
          routed_nest = nests.values.find(&:on_route?)
          next unless routed_nest

          nested_title_field = field(:nested_title)
          child_title_field = routed_nest.component.field(:title)
          child_title_field.attach(nested_title_field) { nested_title_field.invalidate }
          if child_title_field.changed? || routed_nest.selection_changed?
            nested_title_field.invalidate
          end
        end
      end

      def title_changed?
        field(:title).changed?
      end

      module ClassMethods
        def title (&block)
          let(:title, &block)
        end
      end
    end
  end
end
