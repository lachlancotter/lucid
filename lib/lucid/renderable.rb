require "nokogiri"

module Lucid
  module Renderable
    CLOSE_TAG = "</div>".freeze

    def self.included (base)
      base.extend(ClassMethods)
    end

    def render
      # TODO: maybe wrap the arguments in a Proxy object so that we can
      #   defer evaluation until referenced within the template. OR define
      #   them on the render context.
      args = template.parameters.map { |(type, name)| send(name) }
      html = open_tag + template.render(*args) + close_tag
      doc  = Nokogiri::HTML(html)
      doc.to_xhtml(indent: 2, indent_text: ' ')
    end

    def open_tag
      "<div id=\"#{element_id}\">"
    end

    def close_tag
      CLOSE_TAG
    end

    def has_helper? (name)
      respond_to?(name)
    end

    #
    # Access a template/partial to be rendered. Defaults
    # to the main template if no name is provided.
    #
    def template (name = :default)
      template_block = templates.fetch(name.to_sym) do
        raise "Could not find template `#{name}` in #{self.class} at #{config.path}. Available templates: #{templates.keys}"
      end
      Template.new(self, &template_block)
    end

    def templates
      self.class.templates
    end

    def changed?
      @changed == true
    end

    module ClassMethods
      #
      # Defines a template with a name and a block that gives
      # the template definition.
      #
      def template (name = :default, &block)
        @templates       ||= {}
        @templates[name] = block
        if name == :default
          watch(*block.parameters.map(&:last)) { @changed = true }
        end
      end

      #
      # Access the templates hash. Provides a default if none
      # has been defined.
      #
      def templates
        @templates ||= {}
      end
    end
  end
end