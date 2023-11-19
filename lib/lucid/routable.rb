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
      self.class.routes(routes_config)
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
        @route_block = block
      end

      def routes (config)
        @route_block.nil? ?
           Location::Map.new(config) :
           Location::Map.build(config, &@route_block)
      end
    end
  end
end