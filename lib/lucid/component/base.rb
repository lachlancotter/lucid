module Lucid
  module Component
    #
    # Base class for Lucid components.
    #
    class Base

      include Callbacks
      include StateMapping
      include Properties
      include Nesting
      include Fields
      include FieldInheritance
      include Linking
      include Eventing
      include Echoing
      include HTML::Templating
      include Rendering
      include Restricted
      include Title

      #
      # The path from the web server root to the application root.
      # Used to encode URLs for the webserver. Useful if you want to
      # nest your application under a subdirectory.
      #
      prop :app_root, Types.Constructor(Path).default { |path| path["/"] }

      #
      # Access to the environment for the current request.
      # 
      prop :container, Types.container.optional.default { App::Container.new({}, {}) }

      #
      # Access to the Session for the current request.
      #
      prop :session, Types.instance(App::Session).optional.default(nil)

      #
      # This component's parent in the component tree.
      #
      prop :parent, Types.component.optional.default(nil)

      #
      # The name of this component in the parent.
      #
      prop :name, Types.symbol.default("root".freeze)

      #
      # Whether this component is a member of a collection.
      #
      prop :collection_index, Types.integer.optional.default(nil)

      def initialize (state, **props)
        initialize_state(state)
        initialize_props(props)
        run_callbacks(:after_initialize)
        run_callbacks(:after_build)
      end

      #
      # Update a value in the state, and trigger invalidation of
      # dependent fields.
      #
      def update (data)
        @state = @state.new(data)
        data.keys.each { |key| field(key).invalidate if field?(key) }
      rescue Dry::Struct::Error => e
        raise StateError.new(self, data, e.message)
      end

      #
      # Return a Factory for building components of the receiver class with the
      # given configuration.
      #
      def self.[] (**props)
        PropsBinding.new(self, **props)
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
      
      def css_class_name
        class_name = self.class.name
        case class_name
        when String then class_name.gsub(/::/, "-")
        else "anon"
        end
      end

    end
  end
end