module Lucid
  module Routable
    def self.included (base)
      base.extend(ClassMethods)
    end

    #
    # Default routes configuration. Overridden by using the
    # routes class method to define a mapping.
    #
    def routes
      Location::Map.new(routes_config)
    end

    private

    def routes_config
      { app_root: app_root }
    end

    module ClassMethods
      #
      # The route block defines the path components and params
      # to project from the view state.
      #
      def route (&block)
        define_method(:routes) do
          @routes ||= Location::Map.build(routes_config, &block)
        end
      end
    end
  end
end