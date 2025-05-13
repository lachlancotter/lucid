module Lucid
  module Component
    module Rendering
      BASE_TEMPLATE = :__base__

      def self.included (base)
        base.template(BASE_TEMPLATE) { text "Base" }
        base.extend(ClassMethods)
        base.after_initialize { @delta = ChangeSet.new(self) }
      end

      attr_reader :delta

      def render_full
        ChangeSet::Replace.new(self).call
      end

      def render_changes
        changes.to_s
      end

      def changes
        ChangeSet::Branches.new.tap do |branches|
          branches.append_component(self)
        end
      end

      #
      # Return the template to be rendered.
      # 
      def template (name = BASE_TEMPLATE)
        self.class.template(name).bind(self)
      end

      def tag
        self.class.instance_variable_get(:@tag) || :div
      end

      def has_helper? (name)
        respond_to?(name)
      end

      module ClassMethods
        #
        # Define the base template for this component.
        #
        def element (tag = :div, &block)
          template(BASE_TEMPLATE, &block)
          @tag = tag
          watch(*block.parameters.map(&:last)) { delta.replace }
        end
      end
    end
  end
end