module Lucid
  module DSL
    #
    # Define a nested view within a parent view.
    #
    class Nest
      #
      # target_class - The class that will contain the nested view.
      # name         - The name of the nested view.
      # nested_class - The class of the nested view (nil if defined inline).
      # options[:in] - The collection to iterate over (nil if not iterating).
      # options[:as] - The name of the config key to use for the collection item in the nested view.
      # nested_class_def - Optional block to define the nested view inline.
      #
      def initialize (target_class, name, nested_class = nil, **options, &nested_class_def)
        @target_class     = target_class
        @name             = name
        @nested_class     = nested_class
        @options          = options
        @nested_class_def = nested_class_def
      end

      def install
        if collection.nil?
          install_single self
        else
          install_collection self
        end
      end

      def install_single (nest)
        @target_class.define_method(@name) do
          @nest            ||= {}
          @nest[nest.name] ||= nest.build
          # TODO configure the view.
        end
      end

      def install_collection (nest)
        @target_class.define_method(@name) do |collection_key|
          @nest                            ||= {}
          @nest[nest.name]                 ||= []
          @nest[nest.name][collection_key] ||= nest.build do |config|
            config[nest.config_key] = nest.value(self, collection_key)
            config.app_root         = app_root
            config.path             = path.extend(nest.path_component(collection_key)).to_s
          end
        end
      end

      attr_reader :name

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

      def build
        @nested_class ||= Class.new(View, &@nested_class_def)
        @nested_class.new { |config| yield config if block_given? }
      end
    end
  end
end