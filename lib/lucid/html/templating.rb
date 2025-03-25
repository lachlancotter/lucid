module Lucid
  #
  # Include this module to define and retrieve templates in a module.
  # 
  module Templating
    def self.included (base)
      base.extend(ClassMethods)
    end

    class TemplateNotFound < ArgumentError
      def initialize (name, module_namespace)
        super(<<~MSG)
          Could not find template `#{name}` in #{module_namespace}.
          Available templates: #{module_namespace.templates.keys}
        MSG
      end
    end

    module ClassMethods
      #
      # Define a template or retrieve a template by name.
      #
      def template (name, &block)
        if block_given?
          templates[name] = Template.new(&block)
        else
          templates.fetch(name) do
            # Templates are inherited in subclasses.
            if superclass.respond_to?(:template)
              superclass.template(name)
            else
              raise TemplateNotFound.new(name, self)
            end
          end
        end
      end

      def templates
        @templates ||= {}
      end
    end
  end
end