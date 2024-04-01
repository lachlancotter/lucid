module Lucid
  module Component
    #
    # Base class for Lucid components.
    #
    class Base

      include Callbacks
      include Stateful
      include Mappable
      include Configurable
      include Linkable
      include Eventable
      include Nestable
      include Renderable
      include Echoable
      include Dataflow

      # The path from the web root to the application root.
      # Used to encode URLs for the webserver. Useful
      # if you want to nest your application under a subdirectory.
      setting :app_root, default: "/"

      # The path from the root view component to this component.
      # Used to identify components and actions.
      setting :path, default: "/", constructor: -> (path) do
        path.is_a?(Path) ? path : Path.new(path)
      end

      setting :parent, default: nil

      def self.build (buffer, &config)
        new(buffer, &config)
      end

      def initialize (params = {}, &config)
        @params = StateParam.from(params)
        @state  = self.class.build_state(@params)
        configure(&config)
        run_callbacks(:after_initialize)
      end

      def nested_state (key)
        @params.seek(self.class.state_map.path_count, key).tap do |result|
          Check[result].type(State::HashReader, State::Reader)
        end
      end

      def inspect
        "<#{self.class.name || "Component"}(#{path}) #{state.to_h}>"
      end

      def element_id
        config.path.to_s.gsub("/", "-").gsub(/^-/, "")
      end

      class StateParam
        def self.from (data)
          Check[data].type(Hash, State::HashReader, State::Reader)
          data.is_a?(Hash) ? State::HashReader.new(data) : data
        end
      end

    end
  end
end