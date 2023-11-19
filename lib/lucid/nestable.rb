module Lucid
  module Nestable
    def self.included (base)
      base.extend(ClassMethods)
    end

    #
    # Build the nested component.
    #
    def nested (name)
      nest = self.class.nests[name]
      if nest.nil?
        raise ArgumentError,
           "No nested component named #{name} at #{config.path}"
      else
        @nests            ||= {}
        @nests[nest.name] ||= nest.build(
           state_for_nested(nest.name), self
        )
      end
    end

    def nests # Array[Component]
      self.class.nests.keys.map { |name| nested(name) }
    end

    #
    # The state for this and all nested components.
    #
    def deep_state
      nests.inject(state.to_h) do |state, nest|
        state.merge(nest.deep_state)
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

      def nests # Array[Nest]
        @nests ||= {}
      end
    end

    #
    # Build and configure a nested component.
    #
    class Nest
      #
      # @parent_class - The class that will contain the nested view.
      # name          - The name of the nested view in the parent.
      # nested_class  - The class of the nested view (nil if defined inline).
      # options[:in]  - The collection to iterate over (nil if not iterating).
      # options[:as]  - The name of the config key to use for the collection item in the nested view.
      # config_block  - If defining the class inline, the block provides a
      #                 definition for the nested component class.
      #                 If the class if provided in the nested_class argument,
      #                 the block configures an instance of the nested class.
      #
      def initialize (parent_class, name, nested_class = nil, **options, &config_block)
        @parent_class = parent_class
        @name         = name
        @nested_class = nested_class
        @options      = options
        @config_block = config_block
      end

      attr_reader :name, :config_block

      def install
        if collection.nil?
          install_single self
        else
          install_collection self
        end
      end

      def install_single (nest)
        @parent_class.define_method(@name) do
          nested(nest.name)
        end
      end

      def install_collection (nest)
        @parent_class.define_method(@name) do |collection_key|
          nest                              = self.class.nests[nest.name]
          @nests[nest.name]                 ||= []
          @nests[nest.name][collection_key] ||= nest.build do |config|
            config[nest.config_key] = nest.value(self, collection_key)
            config.app_root         = app_root
            config.path             = path.concat(nest.path_component(collection_key)).to_s
          end
        end
      end

      def build (nested_state, parent_component)
        @nested_class.new(nested_state) do |config|
          config.app_root = parent_component.app_root
          config.path     = parent_component.path.concat(@name).to_s
          yield config if block_given?
        end
      end

      def collection
        @options[:in]
      end

      def config_key
        @options[:as] || :model
      end

      def path_component (collection_key)
        "#{@name}[#{collection_key}]"
      end

      def value (target, collection_key)
        if collection.is_a?(Symbol)
          target.send(collection)[collection_key]
        else
          collection[collection_key]
        end
      end
    end

  end
end