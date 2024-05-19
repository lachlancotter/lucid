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
      include Guarded

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
      # The name of this component in the parent.
      #
      prop :name, default: "root"

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
        Factory::Singleton.new(self) { config }
      end

      #
      # Return a Factory for building components of the receiver class that
      # iterates over the given collection.
      #
      def self.enum (collection, &block)
        Factory::Enumerated.new(self, collection, &block)
      end

      def inspect
        "<#{self.class.name || "Component"}(#{path}) #{state.to_h}>"
      end

      def element_id
        if path.root?
          "root"
        else
          path.to_s.gsub("/", "-").gsub(/^-/, "")
        end
      end

    end
  end
end