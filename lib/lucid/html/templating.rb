module Lucid
  module HTML
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
        def template (key, &block)
          if block_given?
            templates[key] = Template.new(&block)
          else
            case key
            when Symbol then template_for_name(key)
            when Class then template_for_class(key)
            else raise ArgumentError, "invalid template key #{key}"
            end
          end
        end

        def template_for_name (name)
          templates.fetch(name) do
            # Templates are inherited in subclasses.
            if superclass.respond_to?(:template_for_name)
              superclass.template_for_name(name)
            else
              raise TemplateNotFound.new(name, self)
            end
          end
        end

        def template_for_class (target_class, current_class = target_class)
          templates.fetch(current_class) do
            if current_class <= StandardError
              # First, search in this component for a template matching a superclass
              # of the target error type.
              template_for_class(target_class, current_class.superclass)
            elsif superclass.respond_to?(:template_for_class)
              # If no suitable template was found, delegate to the component superclass
              # but begin the search from the original target error type.
              superclass.template_for_class(target_class)
            else
              raise TemplateNotFound.new(target_class, self)
            end
          end
        end

        def templates
          @templates ||= {}
        end
      end
    end
  end
end