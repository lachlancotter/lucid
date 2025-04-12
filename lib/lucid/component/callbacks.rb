module Lucid
  module Component
    #
    # Register blocks of code to run at specific points in the component lifecycle.
    # Provides a convenient way to define DSL methods.
    #
    module Callbacks
      def self.included(base)
        base.extend(ClassMethods)
      end

      private

      def run_callbacks (name)
        self.class.callbacks(name).tap do |blocks|
          blocks.each { |block| instance_exec(&block) }
        end
      end

      module ClassMethods
        def after_initialize (&block)
          callbacks_registry[:after_initialize] ||= []
          callbacks_registry[:after_initialize] << block
        end
        
        def after_build (&block)
          callbacks_registry[:after_build] ||= []
          callbacks_registry[:after_build] << block
        end

        def callbacks (name)
          (superclass.respond_to?(:callbacks) ? superclass.callbacks(name) : [])
             .concat(callbacks_registry[name] || [])
        end
        
        private
        
        def callbacks_registry
          @callbacks ||= {}
        end
      end
    end
  end
end