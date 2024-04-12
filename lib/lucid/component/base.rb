module Lucid
  module Component
    #
    # Base class for Lucid components.
    #
    class Base

      include Callbacks
      include Stateful
      include Mapping
      include Configuring
      include Nesting
      include Reacting
      include Linking
      include Responding
      include Echoing
      include Rendering

      # The path from the web root to the application root.
      # Used to encode URLs for the webserver. Useful
      # if you want to nest your application under a subdirectory.
      setting :app_root, default: "/"

      # The path from the root view component to this component.
      # Used to identify components and actions.
      setting :path, default: "/",
         constructor: -> (path) { path.is_a?(Path) ? path : Path.new(path) }

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

      #
      # Return a Factory for building components of the receiver class with the
      # given configuration.
      #
      def self.[] (**config)
        Factory.new(self) { config }
      end

      #
      # Return a Factory for building components of the receiver class that
      # iterates over the given collection.
      #
      def self.enum (collection, &block)
        Factory::Enumerated.new(self, collection, &block)
      end

      #
      # Convenience method for matching values in a block.
      #
      def match (value, &block)
        Match.on(value, &block)
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
        if config.path.root?
          "root"
        else
          config.path.to_s.gsub("/", "-").gsub(/^-/, "")
        end
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