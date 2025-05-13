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
          @component = Types.component[component]
          @attrs     = Types.hash[attrs]
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
          emit Anchor.new(normalize_message(message), text: text, **opts, &block).template
        end

        def button_to (message, text = nil, **opts)
          emit Button.new(normalize_message(message), text, **opts).template
        end

        def form_for (form_model, **opts, &block)
          emit Form.new(form_model, opts, &block).template
        end

        def fragment (name, *a, **b, &block)
          emit @renderable.template(name).render(*a, **b, &block)
        end

        #
        # Render a component in the template.
        # 
        def subview (name_or_component)
          subcomponent = normalize_subview(name_or_component)
          emit Component::ChangeSet::Replace.new(subcomponent).call
        rescue => e
          replace_nest(subcomponent.name.value) { Component::ErrorPage[error: e] }
          retry
        end

        #
        # Render a collection of subcomponents in the template.
        # 
        def subviews (enum_name)
          # Wrap the collection in a div we can target for insertions.
          div(class: @renderable.collection_classname(enum_name)) do
            @renderable.send(enum_name).each do |subcomponent|
              subview(subcomponent)
            end
          end
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

        def normalize_subview (name_or_component)
          case name_or_component
          when Symbol then @renderable.send(name_or_component)
          when Component::Base then name_or_component
          else raise ArgumentError, "Invalid subview type: #{name_or_component.class}"
          end
        end

        def normalize_message (message)
          case message
          when Message then message
          when Symbol then @renderable.link_to(message)
          # when Types.subclass(HTTP::Message) then message.new
          else raise ArgumentError, "Message or Symbol expected: #{message.inspect}"
          end
        end
      end

    end
  end
end