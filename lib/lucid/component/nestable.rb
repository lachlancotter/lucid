module Lucid
  module Component
    #
    # Nestable components can contain other components, defined with
    # the `nest` DSL method.
    #
    module Nestable
      def self.included (base)
        base.extend(ClassMethods)
      end

      #
      # Build the nested component.
      #
      def nested (name, collection_key = nil)
        nest_def = self.class.nests[name]
        if nest_def.nil?
          raise ArgumentError,
             "No nested component named #{name} at #{config.path}"
        else
          @nests                                    ||= {}
          @nests[nest_def.nest_key(collection_key)] ||= nest_def.build(
             state_for_nested(nest_def.name), self, collection_key
          )
        end
      end

      def nests # Hash[Symbol => Component]
        self.class.nests.keys.map do |name|
          [name, nested(name)]
        end.to_h
      end

      #
      # The state for this and all nested components.
      #
      def deep_state
        self.class.nests.keys.inject(state.to_h) do |h, name|
          h.merge(name => nested(name).deep_state)
        end
      end

      module ClassMethods
        # DSL method to define a nested component.
        def nest (name, *args, **options, &block)
          Nest.new(self, name, *args, **options, &block).tap do |nest|
            nests[name] = nest
            nest.install
          end
        end

        def nests # Hash[Symbol => Nest]
          @nests ||= {}
        end
      end

      #
      # Build and configure a nested component.
      #
      class Nest
        #
        # parent_class  - The class that will contain the nested view.
        # name          - The name of the nested view in the parent.
        # constructor   - Class or block that returns a class to instantiate.
        # options[:in]  - The collection to iterate over (nil if not iterating).
        # options[:as]  - The name of the config key to use for the collection item in the nested view.
        # block         - Yielded a configuration object for the instantiated view.
        #
        def initialize (parent_class, name, constructor, **options, &block)
          @parent_class = parent_class
          @name         = name
          @constructor  = constructor
          @options      = options
          @block        = block
        end

        attr_reader :name

        def nested_class
          @nested_class ||= @constructor.is_a?(Class) ?
             @constructor : @constructor.call
        end

        #
        # Install the accessor method in the parent class.
        #
        def install
          nest = self
          if collection.nil?
            @parent_class.define_method(@name) do
              nested(nest.name)
            end
          else
            @parent_class.define_method(@name) do |collection_key|
              nested(nest.name, collection_key)
            end
          end
        end

        def build (nested_state, parent_component, collection_key = nil)
          nested_class.new(nested_state) do |config|
            config.app_root    = parent_component.app_root
            config.path        = nested_path(parent_component, collection_key)
            config[config_key] = value(parent_component, collection_key) if collection_key
            parent_component.instance_exec(config, &@block) if @block
          end
        end

        #
        # The key used to store the nested component in the parent instance.
        #
        def nest_key (collection_key = nil)
          collection_key ? "#{@name}[#{collection_key}]" : @name
        end

        #
        # The path to the nested component instance.
        #
        def nested_path (parent_component, collection_key = nil)
          raise "not a path #{parent_component.path}" unless parent_component.path.is_a?(Path)
          path_component = collection_key ? "#{@name}[#{collection_key}]" : @name
          parent_component.path.concat(path_component)
        end

        def collection
          @options[:in]
        end

        def config_key
          @options[:as] || :model
        end

        #
        # Looks up the value for the given collection key in the parent.
        #
        def value (parent_component, collection_key)
          if collection.is_a?(Symbol)
            parent_component.send(collection)[collection_key]
          else
            collection[collection_key]
          end
        end
      end

    end
  end
end