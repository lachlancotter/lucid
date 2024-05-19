module Lucid
  module Rendering
    BASE_TEMPLATE = :__base__

    def self.included (base)
      base.extend(ClassMethods)
      if base.respond_to?(:after_initialize)
        base.after_initialize { @element = ChangeSet.new(self) }
      end
    end

    attr_reader :element

    def changes
      ChangeSet::Branches.new.tap do |branches|
        branches.append_component(self)
      end
    end

    def render
      changes.to_s
    end

    class TemplateNotFound < ArgumentError
      def initialize (name, context)
        super(<<~MSG)
          Could not find template `#{name}` in #{context.class} at #{context.path}.
          Available templates: #{context.class.templates.keys}
        MSG
      end
    end

    #
    # Access a template/partial to be rendered. Defaults
    # to the main template if no name is provided.
    #
    def template (name = BASE_TEMPLATE)
      Check[name].type(Symbol, String)
      self.class.templates.fetch(name) do
        raise TemplateNotFound.new(name, self)
      end.bind(self)
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
        templates[BASE_TEMPLATE] = Template.new(&block)
        @tag = tag
        watch(*block.parameters.map(&:last)) do
          element.replace
        end
      end

      #
      # Define a template fragment that can be used in other templates.
      #
      def template (name, &block)
        templates[name] = Template.new(&block)
      end

      def templates
        @templates ||= {}
      end
    end
  end
end