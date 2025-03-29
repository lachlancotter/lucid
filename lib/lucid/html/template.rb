require "papercraft"

module Lucid
  module HTML
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
          @attrs     = Check[attrs].hash.value
        end

        def wrap
          if @component.root?
            yield
          else
            "<#{tag}#{attrs}>#{yield}</#{tag}>"
          end
        end

        def tag
          @component.tag
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

        #
        # Explicit access to the context is useful in cases where a helper name
        # conflicts with an HTML element name, and can't be involved implicitly.
        #
        def context
          @renderable
        end

        def link_to (message, text = nil, **opts, &block)
          emit normalize_message(message).link(text, **opts, &block)
        end

        def button_to (message, text = nil, **opts)
          emit normalize_message(message).button(text, **opts)
        end

        def form_for (form_params, **opts, &block)
          emit form_params.form(**opts, &block)
        end

        def fragment (name, *a, **b, &block)
          emit @renderable.template(name).render(*a, **b, &block)
        end

        def subview (name_or_component)
          component = Match.on(name_or_component) do
            type(Symbol) { |name| @renderable.send(name) }
            type(Component::Base) { |component| component }
          end
          emit Component::ChangeSet::Replace.new(component).call
        end

        # TODO maybe we should explicitly expose methods to the template 
        #   instead of using method_missing? This makes the interface muddy
        #   and may have performance implications for Papercraft.
        def method_missing(sym, *args, **opts, &block)
          if @renderable.has_helper?(sym)
            @renderable.send(sym, *args, **opts, &block)
          else
            super
          end
        end

        private

        def normalize_message (message)
          Match.on(message) do
            type(Message) { message }
            extends(HttpMessage) { |klass| klass.new }
            type(Symbol) { |name| @renderable.link_to(name) }
            default do
              raise ArgumentError,
                 "Message type, MessageParms or Symbol expected: #{message.inspect}"
            end
          end
        end
      end

    end
  end
end