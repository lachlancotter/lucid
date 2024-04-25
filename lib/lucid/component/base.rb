module Lucid
  module Component
    #
    # Base class for Lucid components.
    #
    class Base

      include Callbacks
      include StateMap
      include Properties
      include Nesting
      include Fields
      include FieldInheritance
      include Linking
      include Responding
      include Echoing
      include Rendering

      #
      # The path from the web server root to the application root.
      # Used to encode URLs for the webserver. Useful if you want to
      # nest your application under a subdirectory.
      #
      prop :app_root, default: "/"

      #
      # Access to the Session for the current request.
      #
      prop :session

      #
      # This component's parent in the component tree.
      #
      prop :parent, default: nil

      #
      # The path from the root view component to this component.
      # Used to identify components and actions.
      #
      prop :path, default: "/" do |value|
        Match.on(value) do
          type(Path) { value }
          default { Path.new(value) }
        end
      end

      def self.build (buffer, &config)
        new(buffer, &config)
      end

      def initialize (params = {}, &config)
        init_state(params)
        configure(&config)
        run_callbacks(:after_initialize)
      end

      #
      # Update a value in the state, and trigger invalidation of
      # dependent fields.
      #
      def update (data)
        @state.update(data)
        data.keys.each do |key|
          field(key).invalidate if field?(key)
        end
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

      def inspect
        "<#{self.class.name || "Component"}(#{props.path}) #{state.to_h}>"
      end

      def element_id
        if props.path.root?
          "root"
        else
          props.path.to_s.gsub("/", "-").gsub(/^-/, "")
        end
      end

    end
  end
end