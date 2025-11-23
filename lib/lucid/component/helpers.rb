module Lucid
  module Component
    #
    # Declare helper methods, accessible within component templates.
    # 
    module Helpers
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def helper(name, &block)
          # Define a method on the helper module that forwards to the component
          # instance via the @renderable variable in a template context.
          helper_module.define_method(name) do |*args, **opts|
            @renderable.send(name, *args, **opts)
          end
          define_method(name, &block) if block_given?
        end
        
        def helper_module
          @helper_module ||= Module.new
        end
      end
    end
  end
end