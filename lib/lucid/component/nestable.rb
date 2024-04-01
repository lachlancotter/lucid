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

      def nests # Hash[Symbol | String => Component]
        @nests ||= {}
      end

      #
      # The state for this and all nested components.
      #
      def deep_state
        nests.inject(state.to_h) do |hash, (name, sub)|
          hash.merge(name => sub.deep_state)
        end
      end

      module ClassMethods
        # DSL method to define a nested component.
        def nest (name, *args, **options, &block)
          Nest.new(name, *args, **options, &block).tap do |nest_def|
            nests[name] = nest_def
            after_initialize do
              nest_def.instantiate(nests, nested_state(name), self)
            end
            if nest_def.collection.nil?
              define_method(name) do
                nests[nest_def.nest_key]
              end
            else
              define_method(name) do |collection_key|
                nests[nest_def.nest_key(collection_key)]
              end
            end
          end
        end

        def match (key, map)
          Match.new(key, map)
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
        # constructor   - Class or block that returns a class to instantiate.
        # options[:in]  - The collection to iterate over (nil if not iterating).
        # options[:as]  - The name of the config key to use for the collection item in the nested view.
        # block         - Yielded a configuration object for the instantiated view.
        #
        def initialize (name, constructor, **options, &block)
          @name        = name
          @constructor = Check[constructor].has_type(Class, Match).value
          @options     = options
          @block       = block
        end

        def instantiate (hash, reader, parent)
          if collection.nil?
            hash[nest_key] = build(reader, parent)
          else
            collection.each_with_index do |v, n|
              hash[nest_key(n)] = build(reader, parent, n)
            end
          end
        end

        def build (reader, parent_component, collection_key = nil)
          constructor(parent_component).new(reader) do |config|
            config.app_root    = parent_component.app_root
            config.path        = nested_path(parent_component, collection_key)
            config.parent      = parent_component
            config[config_key] = value(parent_component, collection_key) if collection_key
            parent_component.instance_exec(config, &@block) if @block
          end
        end

        def constructor (parent_component)
          Check[parent_component].has_type(Component::Base)
          if @constructor.is_a?(Match)
            @constructor.component_class(parent_component)
          else
            @constructor
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
          Check[collection_key].type(Symbol, Integer)
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