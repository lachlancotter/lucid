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

      def subcomponents # Hash[Symbol => Component::Base]
        nests.map do |(name, nest)|
          [name, nest.component]
        end.to_h
      end

      def subcomponent (name, index = nil)
        Match.on(subcomponents[name]) do
          type(Component::Base) { |sub| sub }
          type(Enumerable) do |enum|
            enum[index].tap do |sub|
              Check[sub].type(Component::Base).value
            end
          end
          default { raise "No subcomponent named #{name}" }
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
        if props.name.match?(/\[\]/)
          props.name.sub(/\[\]$/, "[#{collection_key}]")
        else
          props.name
        end
      end

      def collection_key
        raise "You must define a collection_key method to use collections."
      end

      #
      # The state for this and all nested components.
      #
      def deep_state
        subcomponents.inject(state.to_h) do |hash, (name, sub)|
          hash.merge(name => sub.deep_state)
        end
      end

      #
      # Read state for a nested component.
      #
      private def nested_state (key)
        @params.seek(self.class.state_map.path_count, key).tap do |result|
          Check[result].type(State::HashReader, State::Reader)
        end
      end

      module ClassMethods
        # DSL method to define a nested component.
        def nest (name, component_class = nil, &block)
          Nest.new(name, component_class, &block).tap do |nest|
            nests[name] = nest
            after_initialize do
              nests[name] = nest.bind(self).tap do |binding|
                binding.install(nested_state(name))
              end
            end
            if block_given?
              watch(*block.parameters.map(&:last)) do
                nests[name].update_component(nested_state(name))
              end
            end
            define_method(name) do
              Match.on(nests[name].component) do
                type(Enumerable) { Collection.new(nests[name]) }
                default { |component| component }
              end
            end
          end
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
      class Collection
        def initialize (nest_binding)
          Check[nest_binding].type(Nest::Binding)
          Check[nest_binding.component].type(Enumerable)
          @nest_binding = nest_binding
        end

        def [] (index)
          @nest_binding.component[index]
        end

        def append (props)
          build(props).tap do |component|
            @nest_binding.collection.push(component)
            parent.element.append(component)
          end
        end

        def prepend (props)
          build(props).tap do |component|
            @nest_binding.collection.unshift(component)
            parent.element.prepend(component)
          end
        end

        private

        def collection_size
          @nest_binding.collection.size
        end

        def build (props)
          @nest_binding.build(props).tap do |component|
            Check[component].type(Component::Base)
          end
        end

        def parent
          @nest_binding.parent
        end
      end

      #
      # Build and configure a nested component.
      #
      class Nest
        #
        # name - The name of the nested component within the parent.
        # component_class - The class of the nested component.
        # constructor - A block returning a Factory instance that can
        # build the nested component; or an enumerable that maps to
        # a Factory.
        #
        def initialize (name, component_class = nil, &block)
          @name  = name
          @block = normalize_constructor(component_class, &block)
        end

        attr_reader :name, :block

        def bind (parent)
          Binding.new(self, parent)
        end

        private

        def normalize_constructor (component_class, &block)
          block_given? ? block : lambda { Factory.new(component_class) { {} } }
        end

        #
        # Bind a Nest expression to a concrete component instance.
        #
        class Binding
          extend Forwardable

          def initialize (nest, parent)
            @nest      = nest
            @parent    = parent
            @component = nil
          end

          attr_reader :component, :parent

          def_delegators :@nest, :name, :block

          def collection
            @component
          end

          def install (reader)
            @component = factory.build(reader, @parent, name)
          end

          def build (props)
            factory.build_one(@parent, name, props)
          end

          def update_component (reader)
            if @component.is_a?(component_class)
              factory.update_props(@component)
            else
              @component = factory.build(reader, @parent, name)
              @component.element.replace
            end
          end

          def factory
            object = @parent.instance_exec(*factory_args, &block)
            Match.on(object) do
              type(Factory) { object }
              extends(Component::Base) { Factory.new(object) { {} } }
            end.tap do |result|
              Check[result].type(Factory)
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