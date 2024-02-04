require "papercraft"

module Lucid
  #
  # Render PaperScript templates with a bound view context.
  #
  class Template < Papercraft::Template
    def initialize(renderable, &block)
      raise "Template requires a block" unless block_given?
      super(mode: :html, &block)
      @renderable = renderable
    end

    def to_s
      render
    end

    def render (*args, **opts, &block)
      template = self
      ::Papercraft::Renderer.verify_proc_parameters(template, args, opts)
      BoundRenderer.new(@renderable) do
        push_emit_yield_block(block) if block
        instance_exec(*args, **opts, &template)
      end.to_s
    end

    #
    # Extends Papercraft::HTMLRenderer to provide access to the view context.
    #
    class BoundRenderer < Papercraft::HTMLRenderer
      def initialize(renderable, &block)
        @renderable = renderable
        super(&block)
        # Ensure all HTML elements are defined as methods on the renderer.
        # Papercraft uses method_missing to define element methods on the fly.
        # Since we're using method_missing to delegate to the view, we need
        # to define all the HTML elements as methods on the renderer.
        define_tag_method("label") unless respond_to?(:label)
      end

      def state
        @renderable.state
      end

      def context
        @renderable
      end

      def link (name)
        @renderable.link(name)
      end

      # def action (name)
      #   @renderable.send(name)
      # end

      def emit_template (name, *a, **b, &block)
        emit @renderable.template(name).render(*a, **b, &block)
      end

      def emit_view (name_or_instance, *a, **b, &block)
        # puts "emit_view: #{name_or_instance.inspect}"
        if name_or_instance.is_a?(Component)
          subview = name_or_instance
          emit subview.render(*a, **b, &block)
        else
          view_name = name_or_instance
          subview   = @renderable.nested(view_name)
          emit subview.render(*a, **b, &block)
        end
      end

      # TODO maybe we should explicitly expose methods to the template
      #   instead of using method_missing?
      def method_missing(sym, *args, **opts, &block)
        # puts "method_missing: #{sym}"
        if @renderable.respond_to?(sym)
          @renderable.send(sym, *args, **opts, &block)
        else
          super
        end
      end
    end

  end
end
