module Lucid
  module Rendering
    DEFAULT_TEMPLATE = :default

    def self.included (base)
      base.extend(ClassMethods)
      if base.respond_to?(:after_initialize)
        base.after_initialize { @render = Render.new(self) }
      end
    end

    attr_reader :render

    class TemplateNotFound < ArgumentError
      def initialize (name, context)
        super(<<~MSG)
          Could not find template `#{name}` in #{context.class} at #{context.config.path}.
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
          watch(*block.parameters.map(&:last)) { render.replace }
        end
      end

      def templates
        @templates ||= {}
      end
    end

    #
    # A fluent interface to render a component in two steps.
    # Step one is setting the render configuration.
    # Step two is calling the render method.
    # This allows for a separation of concerns between the
    # logic of deciding what to render, and the actual rendering.
    #
    class Render
      NONE    = nil
      REPLACE = :replace
      APPEND  = :append
      PREPEND = :prepend

      def initialize (component)
        @component     = component
        @template_name = DEFAULT_TEMPLATE
        @mode          = NONE
      end

      def replace
        tap do
          @mode          = REPLACE
          @template_name = DEFAULT_TEMPLATE
        end
      end

      def any?
        @mode != NONE
      end

      def call
        return "" if @mode == NONE
        raise "No template specified" if @template_name.nil?
        to_s
      end

      #
      # If this component is marked for rendering, then render it.
      # Otherwise, search for nested components that are marked for
      # rendering and render them.
      #
      def changes (buffer = "")
        if any?
          buffer << to_s
        else
          @component.nests.each do |(name, sub)|
            sub.render.changes(buffer)
          end
        end
        buffer
      end

      def to_s
        template.render(*template_args)
      end

      private

      def template_args
        # TODO: maybe wrap the arguments in a Proxy object so that we can
        #   defer evaluation until referenced within the template. OR define
        #   them on the render context.
        template.parameters.map do |(type, name)|
          @component.field(name).value
        end
      end

      def template
        @component.template(@template_name)
      end
    end
  end
end