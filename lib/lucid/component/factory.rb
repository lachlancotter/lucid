module Lucid
  module Component
    #
    # Build a nested component instance with the given configuration.
    #
    # component_class - Class of the component to build.
    # config          - Block that returns a hash of configuration values.
    #
    class Factory
      def initialize (component_class, &config)
        Check[component_class].extends(Component::Base)
        @component_class = component_class
        @config          = config
      end

      attr_reader :component_class

      #
      # Instantiate a new component from the factory configuration.
      #
      def build (reader, parent, name, config = Check[@config.call].hash.value)
        @component_class.new(reader) do
          {}.tap do |props|
            props[:parent]   = parent
            props[:app_root] = parent.props.app_root
            props[:path]     = parent.props.path.concat(name)
            config.each { |k, v| props[k] = v }
          end
        end
      end

      #
      # Update an existing component with new configuration.
      #
      def update_props (component, config = Check[@config.call].hash.value)
        component.configure { component.props.to_h.merge(config) }
      end

      #
      # Enumerate the Factory over objects in an enumerable.
      #
      # enumerable - The enumerable to iterate over.
      # config     - A block that takes an item and an index and returns a hash
      #             of configuration values.
      #
      class Enumerated < Factory
        def initialize (component_class, enumerable, &config)
          super(component_class, &config)
          @enumerable = enumerable
        end

        def build (reader, parent, name)
          @enumerable.map.with_index do |item, index|
            super(reader, parent, "#{name}[#{index}]",
               Check[@config.call(item, index)].hash.value
            )
          end
        end
      end
    end

  end
end