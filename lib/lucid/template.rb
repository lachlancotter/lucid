require "papercraft"

module Lucid
  #
  # Encapsulates a template for rendering a view.
  #
  class Template < Papercraft::Template
    def initialize (&block)
      raise "Template requires a block" unless block_given?
      super(mode: :html, &block)
    end

    def bind (renderable)
      Binding.new(self, renderable)
    end

    #
    # Binds a template to an instance of a renderable object such as a component,
    # which provides context to the template during rendering.
    #
    class Binding
      def initialize (template, renderable)
        @template   = template
        @renderable = renderable
      end

      def render (*args, **opts, &block)
        template = @template
        ::Papercraft::Renderer.verify_proc_parameters(template, args, opts)
        RenderContext.new(@renderable) do
          push_emit_yield_block(block) if block
          instance_exec(*args, **opts, &template)
        end.to_s
      end

      def parameters
        @template.parameters
      end
    end

    #
    # Wraps template content in a container element. Needed to
    # ensure that components are addressable by ID.
    #
    class Wrapper
      def initialize (component, attrs)
        @component = component
        @attrs     = attrs
      end

      def wrap
        if @component.root?
          yield
        else
          "<div#{attrs}>#{yield}</div>"
        end
      end

      def attrs
        if @attrs.any?
          " " + @attrs.map { |k, v| "#{k}=\"#{v}\"" }.join(" ")
        else
          ""
        end
      end
    end

    #
    # Extends Papercraft::HTMLRenderer to provide access to the view context.
    #
    class RenderContext < Papercraft::HTMLRenderer
      def initialize(renderable, &block)
        @renderable = renderable
        super(&block)
        # Ensure all HTML elements are defined as methods on the renderer.
        # Papercraft uses method_missing to define element methods on the fly.
        # Since we're using method_missing to delegate to the view, we need
        # to define all the HTML elements as methods on the renderer.
        define_tag_method("label") unless respond_to?(:label)
      end

      def fragment (name, *args, **opts)
        @renderable.template(name, *args, **opts)
      end

      def component (name)
        @renderable.nested(name)
      end

      #
      # Explicit access to the context is useful in cases where a helper name
      # conflicts with an HTML element name, and can't be involved implicitly.
      #
      def context
        @renderable
      end

      def link_to (name, params)
        @renderable.link_to(name, params)
      end

      # def emit (*args, **opts, &block)
      #   if content.is_a?(Component::Base)
      #     super
      #   elsif content.is_a?(Template)
      #     super
      #   else
      #     super(*args, **opts, &block)
      #   end
      # end

      def emit_template (name, *a, **b, &block)
        emit @renderable.template(name).render(*a, **b, &block)
      end

      def emit_view (name_or_instance)
        sv = subview(name_or_instance)
        emit sv.render.replace.call(id: sv.element_id)
      end

      def subview (name_or_instance)
        Match.on(name_or_instance) do
          instance_of(Component::Base) { |instance| instance }
          instance_of(Symbol) { |name| @renderable.send(name) }
          default { raise ArgumentError, "Invalid view: #{name_or_instance}" }
        end
      end

      # TODO maybe we should explicitly expose methods to the template
      #   instead of using method_missing?
      def method_missing(sym, *args, **opts, &block)
        if @renderable.has_helper?(sym)
          @renderable.send(sym, *args, **opts, &block)
        else
          super
        end
      end
    end

  end
end
