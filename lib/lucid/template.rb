module Lucid
  #
  # Render PaperScript templates with a view context.
  #
  class Template
    def initialize(view, &block)
      raise "Template requires a block" unless block_given?
      @view  = view
      @block = block
    end

    def to_s
      render
    end

    def render (*a, **b, &block)
      BoundTemplate.new(@view, mode: :html, &@block).render(*a, **b, &block)
    end

    #
    # Extends Papercraft::Template to provide access to the view context
    # without explicit block parameters. This is done by instantiating
    # a custom renderer that captures the view context.
    #
    class BoundTemplate < Papercraft::Template
      def initialize(view, mode: nil, mime_type: nil, &block)
        @view = view
        super(mode: mode, mime_type: mime_type, &block)
      end

      def render(*a, **b, &block)
        template = self
        ::Papercraft::Renderer.verify_proc_parameters(template, a, b)
        build_renderer do
          push_emit_yield_block(block) if block
          instance_exec(*a, **b, &template)
        end.to_s
      end

      def build_renderer(&block)
        BoundRenderer.new(@view, &block)
      end
    end

    #
    # Extends Papercraft::HTMLRenderer to provide access to the view context.
    #
    class BoundRenderer < Papercraft::HTMLRenderer
      def initialize(view, &block)
        @view = view
        super(&block)
      end

      def state
        @view.state
      end

      def action (name)
        @view.send(name)
      end

      def emit_template (name, *a, **b, &block)
        emit @view.template(name).render(*a, **b, &block)
      end

      def emit_view (name_or_instance, *a, **b, &block)
        puts "emit_view: #{name_or_instance.inspect}"
        if name_or_instance.is_a?(Component)
          subview = name_or_instance
          emit subview.render(*a, **b, &block)
        else
          view_name = name_or_instance
          subview = @view.nested(view_name)
          emit subview.render(*a, **b, &block)
        end
      end

      def method_missing(sym, *args, **opts, &block)
        if @view.respond_to?(sym)
          @view.send(sym, *args, **opts, &block)
        else
          super
        end
      end
    end

  end
end
