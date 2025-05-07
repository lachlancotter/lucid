module Lucid
  module Component
    module ErrorHandling

      def self.included(base)
        base.prepend(SemanticErrorTemplateOverride)
        base.prepend(StateErrorTemplateOverrides)
      end

      module StateErrorTemplateOverrides
        def template (name = Rendering::BASE_TEMPLATE)
          if invalid?
            self.class.template(@error.class).bind(self)
          else
            super
          end
        end
      end

      module SemanticErrorTemplateOverride
        def template (name = Rendering::BASE_TEMPLATE)
          binding = self.class.template(name).bind(self)
          error   = binding.error
          if error
            @error = error
            self.class.template(error.class).bind(self)
          else
            super
          end
        end
      end

      # ===================================================== #
      #    Error Predicates
      # ===================================================== #

      def error
        @error
      end

      def valid?
        !invalid?
      end

      def invalid?
        case @error
        when ParamError then true
        when ConfigError then true
        when StateError then true
        else false
        end
      end

    end
  end
end