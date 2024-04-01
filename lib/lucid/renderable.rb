require "nokogiri"

module Lucid
  module Renderable
    DEFAULT_TEMPLATE = :default

    def self.included (base)
      base.extend(ClassMethods)
      if base.respond_to?(:after_initialize)
        base.after_initialize { @render = Render.new(self) }
      end
    end

    attr_reader :render

    #
    # Access a template/partial to be rendered. Defaults
    # to the main template if no name is provided.
    #
    def template (name = DEFAULT_TEMPLATE)
      Check[name].type(Symbol, String)
      template_block = templates.fetch(name.to_sym) do
        raise "Could not find template `#{name}` in #{self.class} at #{config.path}. Available templates: #{templates.keys}"
      end
      Template.new(self, &template_block)
    end

    def templates
      self.class.templates
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
        templates[name] = block
        if name == DEFAULT_TEMPLATE
          watch(*block.parameters.map(&:last)) { render.replace }
        end
      end

      def templates
        @templates ||= {}
      end
    end

    #
    # A fluent interface to render a component.
    #
    class Render
      NONE    = nil
      REPLACE = :replace
      APPEND  = :append
      PREPEND = :prepend

      OPEN_TAG  = '<div id="ELEMENT_ID">'.freeze
      CLOSE_TAG = '</div>'.freeze

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
        Nokogiri::HTML(to_s).to_xhtml(indent: 2, indent_text: ' ').to_s
      end

      def changes (buffer = "")
        if any?
          buffer << to_s
        else
          @component.nests.each { |(name, sub)| sub.render.changes(buffer) }
        end
        buffer
      end

      def to_s
        open_tag + template.render(*template_args) + close_tag
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

      def open_tag
        OPEN_TAG.sub("ELEMENT_ID", @component.element_id)
      end

      def close_tag
        CLOSE_TAG
      end
    end
  end
end