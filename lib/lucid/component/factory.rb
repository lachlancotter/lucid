module Lucid
  module Component
    #
    # Shared logic for building nested components.
    #
    class Factory
      #
      # All components in the tree need these standard props.
      #
      def default_props (parent, name, member = false)
        {
           parent:            parent,
           app_root:          parent.props.app_root,
           session:           parent.props.session,
           name:              name,
           collection_member: member
        }
      end

      #
      # Instantiate a nested component instance with the given configuration.
      #
      # component_class - Class of the component to build.
      # config          - Block that returns a hash of configuration values.
      #
      class Singleton < Factory
        def initialize (component_class, &config_block)
          @component_class = Types.subclass(Component::Base)[component_class]
          @config_block    = config_block
        end

        attr_reader :component_class

        def build (reader, parent, name)
          @component_class.new(reader, **build_props(parent, name))
        end

        #
        # Called when dependencies of the config block have changed. Update
        # the existing component with the new configuration.
        #
        def update_component (component)
          custom_props.tap do |props|
            component.initialize_props(component.props.to_h.merge(props))
            props.keys.each { |key| component.field(key).invalidate if component.field?(key) }
          end
        end

        private

        def build_props (parent, name)
          default_props(parent, name).merge(custom_props)
        end

        def custom_props
          Types.hash[@config_block.call]
        end
      end

      #
      # Instantiate a collection of components from the factory configuration.
      #
      # enumerable - The enumerable to iterate over.
      # config     - A block that takes an item and an index and returns a hash
      #             of props for the subcomponent.
      #
      class Enumerated < Factory
        def initialize (component_class, enumerable, &config_block)
          @component_class = Types.subclass(Component::Base)[component_class]
          @enumerable      = Types.enumerable[enumerable]
          @config_block    = Types.callable[config_block]
        end

        def build (reader, parent, name)
          # State reader not yet implemented for enumerated components.
          @enumerable.map.with_index do |item, index|
            build_item(parent, name, item, index)
          end
        end

        #
        # Called when dependencies of the config block have changed. Update
        # the existing component with the new configuration.
        #
        def update_collection (collection)
          @enumerable.map.with_index do |item, index|
            custom_props(item, index).tap do |props|
              component = collection[index]
              component.configure { component.props.to_h.merge(props) }
              props.keys.each { |key| component.field(key).invalidate if component.field?(key) }
            end
          end
        end

        def build_item (parent, name, item, index)
          @component_class.new({}, **build_props(parent, name, item, index))
        end

        private

        def build_props (parent, name, item, index)
          default_props(parent, name, true).merge(custom_props(item, index))
        end

        def custom_props (item, index)
          Types.hash[@config_block.call(item, index)]
        end
      end
    end

  end
end