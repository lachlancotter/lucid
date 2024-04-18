module Lucid
  module Component
    #
    # Nestable components can contain other components, defined with
    # the `nest` DSL method.
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

      def subcomponent (name)
        subcomponents[name].tap do |sub|
          Check[sub].type(Component::Base)
        end
      end

      def root?
        props.parent.nil?
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
                binding.build(nested_state(name))
              end
            end
            if block_given?
              watch(*block.parameters.map(&:last)) { nests[name].update_props }
            end
            define_method(name) do |collection_key = nil|
              nests[name].get(collection_key)
            end
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

          attr_reader :component

          def_delegators :@nest, :name, :block

          def build (reader)
            @component = factory.build(reader, @parent, name)
          end

          def update_props
            factory.update_props(@component)
          end

          def get (collection_key = nil)
            Match.on(collection_key) do
              type(NilClass) { @component }
              type(Integer) { @component[collection_key] }
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