module Lucid
  module Rendering
    DEFAULT_TEMPLATE = :default

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
    def template (name = DEFAULT_TEMPLATE)
      Check[name].type(Symbol, String)
      self.class.templates.fetch(name) do
        raise TemplateNotFound.new(name, self)
      end.bind(self)
    end

    def has_helper? (name)
      respond_to?(name)
    end

    module ClassMethods
      #
      # Defines a template with a name and a block that gives
      # the template definition.
      #
      def template (name = DEFAULT_TEMPLATE, &block)
        templates[name] = Template.new(&block)

        if name == DEFAULT_TEMPLATE
          watch(*block.parameters.map(&:last)) do
            element.replace
          end
        end
      end

      def templates
        @templates ||= {}
      end
    end
  end
end