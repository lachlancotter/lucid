module Lucid
  module Rendering
    BASE_TEMPLATE   = :__base__
    DENIED_TEMPLATE = :__denied__

    def self.included (base)
      base.template(BASE_TEMPLATE) { text "Base" }
      base.template(DENIED_TEMPLATE) { text "Denied" }
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
    # Access a template/partial to be rendered. Defaults
    # to the main template if no name is provided.
    #
    def template (name = BASE_TEMPLATE)
      if denied?
        self.class.template(DENIED_TEMPLATE).bind(self)
      else
        self.class.template(name).bind(self)
      end
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