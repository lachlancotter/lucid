module Lucid
  module Component
    #
    # Allows nesting of subcomponents within parent components using the
    # `nest` DSL method. And propagates updates to the nested components.
    #
    module Nesting
      def self.included (base)
        base.extend(ClassMethods)
      end

      def nests # Hash[Symbol => Nest::Binding]
        @nests ||= {}
      end

      def subcomponents # Hash[Symbol => Component::Base | Enumerable]
        nests.map do |(name, nest)|
          [name, nest.enum? ?
             Types.collection[nest.collection] :
             Types.component[nest.component]
          ]
        end.to_h
      end

      def subcomponent (name, index = nil)
        nest = nests.fetch(name) { raise "No subcomponent named #{name}" }
        nest.enum? ? nest.collection[index] : nest.component
      end

      def each_subcomponent (&block)
        subcomponents.values.flatten.each do |sub|
          block.call(Types.component[sub])
        end
      end

      def root?
        props.parent.nil?
      end

      def path
        if root?
          Path.new
        else
          props.parent.path.concat(component_name)
        end
      end

      def component_name
        if props.collection_member
          "#{props.name}-#{collection_key}"
        else
          props.name
        end
      end

      def collection_key
        raise "You must define a collection_key method to use collections."
      end

      #
      # CSS class name for the div wrapping the collection of nested components.
      # 
      def collection_classname (collection_name)
        "#{collection_name}-items"
      end

      module ClassMethods
        # DSL method to define a nested component.
        def nest (name, &block)
          Nest.new(name, &block).tap do |nest|
            nests[name] = nest
            after_initialize do
              nests[name] = nest.bind(self, nested_state(name))
            end
            if block_given?
              watch(*block.parameters.map(&:last)) do
                nests[name].update_component(nested_state(name))
              end
            end
            define_method(name) do
              if nests[name].enum?
                nests[name].collection
              else
                nests[name].component
              end
            end
          end
        end

        #
        # Defines a slot for a nested component provided as a prop.
        #
        def slot (name)
          prop name, Types.subclass(Component::Base)
          nest(name) { props[name] }
          watch(name) { nests[name].update_component(nested_state(name)) }
        end

        def nests # Hash[Symbol => Nest]
          @nests ||= {}
        end

        def key (&block)
          define_method(:collection_key) { instance_eval(&block) }
        end
      end

      #
      # An interface to access members of a nested component collection
      # and to make insertions into the collection, triggering updates
      # to the element ChangeSet.
      #
      class Collection < SimpleDelegator
        def initialize (nest_binding, collection)
          @nest_binding = Types.instance(Nest::Binding)[nest_binding]
          super(Types.enumerable[collection])
        end

        def append (model)
          build(model).tap do |subcomponent|
            collection_selector = "." + parent.collection_classname(collection_name)
            parent.delta.append(subcomponent, to: collection_selector)
          end
        end

        def prepend (model)
          build(model).tap do |subcomponent|
            collection_selector = "." + parent.collection_classname(collection_name)
            parent.delta.prepend(subcomponent, to: collection_selector)
          end
        end

        def build (model)
          @nest_binding.build(model)
        end

        def parent
          Types.component[@nest_binding.parent]
        end

        def collection_name
          Types.symbol[@nest_binding.name]
        end

        def is_a? (klass)
          self.__getobj__.is_a?(klass) || super
        end

        def === (other)
          self.__getobj__ === other || super
        end
      end

      #
      # Build and configure a nested component.
      #
      class Nest
        #
        # name - The name of the nested component within the parent.
        # constructor - A block returning a Factory instance that can
        # build the nested component; or an enumerable that maps to
        # a Factory.
        #
        def initialize (name, &block)
          @name  = name
          @block = block
        end

        attr_reader :name, :block

        def bind (parent, reader)
          Binding.new(self, parent, reader)
        end

        #
        # Bind a Nest expression to a concrete component instance.
        #
        class Binding
          extend Forwardable

          def initialize (nest, parent, reader)
            @nest   = nest
            @parent = parent
            install(reader)
          end

          attr_reader :parent, :component, :collection
          def_delegators :@nest, :name, :block

          def install (reader)
            factory.build(reader, @parent, name).tap do |result|
              case result
              when Component::Base
                @component = result
              when Enumerable
                @collection = Collection.new(self, result)
              else
                raise "Unexpected component type: #{result.class}"
              end
            end
          end

          def on_route?
            @parent.routes_to?(self)
          end

          def enum?
            @collection.is_a?(Collection)
          end

          def build (model, index = collection.size)
            factory.build_item(@parent, name, model, index)
          end

          def update_component (reader)
            if @component.is_a?(component_class)
              factory.update_component(@component)
            else
              install(reader)
              @component.delta.replace
            end
          end

          def update_collection (reader) end

          def factory
            block_result = @parent.instance_exec(*factory_args, &block)
            case block_result
            when Factory then block_result
            when -> (k) { k <= Component::Base } then Factory::Singleton.new(block_result) { {} }
            else raise ArgumentError, "Invalid factory: #{block_result.class}"
            end
          end

          def component_class
            factory.component_class
          end

          #
          # Query the component for the arguments to pass to the block.
          #
          def factory_args
            block.parameters.map { |(type, name)| @parent.field(name).value }
          end
        end

      end
    end
  end
end