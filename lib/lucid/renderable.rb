require "lucid/template"
require "nokogiri"

module Lucid
  module Renderable
    def self.included (base)
      base.extend(ClassMethods)
    end

    def render
      html = template.render
      doc  = Nokogiri::HTML(html)
      doc.to_xhtml(indent: 2, indent_text: ' ')
    end

    #
    # Access a template/partial to be rendered. Defaults
    # to the main template if no name is provided.
    #
    def template (name = :default, *args, **opts)
      template_block = templates.fetch(name.to_sym) do
        raise "Could not find template `#{name}` in #{self.class} at #{config.path}. Available templates: #{templates.keys}"
      end
      Template.new(self, *args, **opts, &template_block)
    end

    def templates
      self.class.templates
    end

    module ClassMethods
      #
      # Defines a template with a name and a block that gives
      # the template definition.
      #
      def template (name = :default, &block)
        raise "Attempt to define template without a block" if block.nil?
        @templates       ||= {}
        @templates[name] = block
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