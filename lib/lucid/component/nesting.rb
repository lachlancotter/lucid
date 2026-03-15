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

      def nests # Hash[Symbol => Nest]
        @nests ||= {}
      end

      def subcomponents # Hash[Symbol => Component::Base | Nesting::Collection]
        nests.map { |(name, nest)| [name, nest.content] }.to_h
      end

      def subcomponent (name, index = 0)
        nest = nests.fetch(name) { raise "No subcomponent named #{name}" }
        nest.component(index)
      end

      def each_subcomponent (&block)
        nests.each do |(name, nest)|
          nest.each_component do |subcomponent|
            block.call(subcomponent)
          end
        end
      end

      def nested_route_component
        subcomponent self.class.instance_variable_get(:@nested_route_component)
      end

      def root?
        props&.parent.nil? || false
      end

      def path
        if root?
          Path.new
        else
          props.parent.path.concat(component_name)
        end
      end

      def coordinate
        if root?
          []
        else
          props.parent.coordinate + [props.ordinal]
        end
      end

      def component_name
        case props.collection_index
        when NilClass then props.name
        else "#{props.name}-#{collection_key}"
        end
      end

      def collection_key
        props.collection_index
      end

      #
      # CSS class name for the div wrapping the collection of nested components.
      # 
      def collection_classname (collection_name)
        "#{collection_name}-items"
      end

      module ClassMethods
        #
        # Define a builder for a nested component.
        # 
        # def build (klass, *signals, **signal_map)
        #   builders[klass] = Builder.new(klass, SignalMap.new(*signals, **signal_map))
        # end
        #
        # def builders
        #   @builders ||= {}
        # end

        #
        # Define a nested component.
        # 
        def static_nest (name, klass = nil, *signals, **signal_map, &block)
          after_initialize do
            nests[name] = case klass
            when NilClass then DynamicNest.new(self, name, &block)
            else StaticNest.new(self, name, klass, *signals, **signal_map)
            end
            nests[name].install(nested_state(name))
          end
          define_method(name) { nests[name].content }
        end

        # 
        # Defines a nested component.
        # name - The name of the nested component in the parent.
        # over - Name of an enumerable field to map over. Optional.
        # block - Function returning a Factory instance for building the component.
        # 
        def nest (name, &block)
          after_initialize do
            nests[name] = Nest.new(name, nests.count, self, &block)
            # nests[name] = case over
            # when Symbol then CollectionNest.new(name, nests.count, self, over, &block)
            # when Enumerable then CollectionNest.new(name, nests.count, self, over, &block)
            # when NilClass then ComponentNest.new(name, nests.count, self, &block)
            # else raise ArgumentError, "Invalid enumerable"
            # end
          end
          after_application do
            # Refactor so that @message is yielded to the callback block.
            # nests[name].install(nested_state(name), @message)
            nested_reader = @state_reader.descend(
               self.class.state_map.path_count,
               nests[name].ordinal
            )
            nests[name].install(nested_reader, @message)
          end
          define_method(name) { nests[name].content }
        end

        #
        # Defines a slot for a nested component provided as a prop.
        #
        def slot (name)
          prop name, Types.subclass(Component::Base)
          nest(name) { props[name].value }
          # watch(name) { nests[name].update_component(nested_state(name)) }
        end

        def key (&block)
          define_method(:collection_key) { instance_eval(&block) }
        end

      end

      # ===================================================== #
      #    Factory
      # ===================================================== #

      #
      # A configuration of property maps and message scopes that
      # can be used to instantiate components for the nest.
      # 
      class Factory
        attr_reader :component_class

        def initialize (component_class, *list, **map)
          @component_class = Types.subclass(Component::Base)[component_class]
          @signal_map      = SignalMap.new(*list, **map)
          @enumerator      = NilEnumerator.new # empty by default
          @cases           = {}
        end

        def enum (collection, as:)
          tap do
            @as         = as
            @enumerator = Enumerator.new(collection, as: as)
          end
        end

        def for (event_type, &block)
          tap do
            @cases[event_type] = Enumerator.new(block, as: @as)
          end
        end

        def call (state, message, parent, name, ordinal, collection_index: nil, element: nil)
          @component_class.new(state, message,
             **build_props(parent, name, ordinal, collection_index, element: element)
          )
        end

        def enumerate (state, message, parent, name, ordinal, &block)
          enumerator_for(message).each(parent, message) do |element, collection_index|
            yield call(state, message, parent, name, ordinal,
               collection_index: collection_index, element: element)
          end
        end

        def enumerator_for (message)
          @cases.fetch(message.class) { @enumerator }
        end

        def enum?
          @enumerator.is_a?(Enumerator)
        end

        private

        def build_props (parent, name, ordinal, collection_index, element: nil)
          config(parent, name, ordinal, collection_index).merge(
             @signal_map.apply(parent),
             case element
             when NilClass then @enumerator.from_index(parent, collection_index)
             else @enumerator.from_element(parent, element)
             end
          )
        end

        def config (parent, name, ordinal, collection_index)
          {
             parent:           parent,
             name:             name,
             ordinal:          ordinal,
             collection_index: collection_index,
             app_root:         parent.props.app_root,
             http_session:     parent.props.http_session,
             container:        parent.props.container,
          }
        end

        #
        # Map a list of component fields to the fields in a parent component, 
        # so they can be passed by reference to a nested component.
        # 
        class SignalMap
          def initialize (*list, **map)
            @list = Types.array(Types.symbol)[list]
            @map  = map
          end

          def apply (component)
            Hash[
               @list.map do |name|
                 [name, component.field(name)]
               end + @map.map do |dest, source|
                 [dest, signal(component, source)]
               end
            ]
          end

          def signal (component, source)
            case source
            when Symbol then component.field(source)
            else Field.new(component) { source }
            end
          end
        end

        class Enumerator
          def initialize (collection, as:)
            @collection = (Types.symbol | Types.enumerable | Types.callable)[collection]
            @as         = as
          end

          def each (component, message, &block)
            collection(component, message).each_with_index(&block)
          end

          def collection (component, message)
            case @collection
            when Symbol then component.field(@collection).value
            when Proc then
              block_result = @collection.call(message)
              case block_result
              when Enumerable then block_result
              else [block_result]
              end
            when Enumerable then @collection
            else raise StandardError
            end
          end

          def from_index (component, index)
            {
               @as => lookup(component, index)
            }
          end

          def from_element (component, element)
            {
               @as => Field.new(component) { element }
            }
          end

          private

          def lookup (component, index)
            Types.integer[index]
            collection = @collection
            Field.new(component) do
              case collection
              when Symbol
                component.field(collection).value[index]
              when Enumerable
                collection[index]
              else
                raise StandardError
              end
            end
          end
        end

        class NilEnumerator
          def from_index (component, index)
            {}
          end

          def from_element (component, index)
            {}
          end
        end
      end

      # ===================================================== #
      #    Nest
      # ===================================================== #

      #
      # Manages a subcomponent (or collection of subcomponents)
      # within a parent component.
      # 
      class Nest
        attr_reader :parent, :name, :ordinal

        def initialize (name, ordinal, parent, &block)
          @parent     = parent
          @name       = Types.symbol[name]
          @ordinal    = Types.integer[ordinal]
          @field      = Field.new(@parent, &block)
          @components = []
        end

        def install (state, message)
          if collection?
            install_collection(state, message)
          else
            install_singleton(state, message)
          end
        end

        def install_singleton (state, message)
          @components = [factory.call(state, message, @parent, @name, @ordinal)]
        rescue StandardError => error
          App::Logger.exception(@parent, error)
          @components = [ErrorPage.new({}, error: error)]
        end

        def install_collection (state, message)
          @components = [].tap do |result|
            factory.enumerate(state, message, @parent, @name, @ordinal) do |component|
              result << component
            end
          end
        rescue StandardError => error
          App::Logger.exception(@parent, error)
          @components = [ErrorPage.new({}, error: error)]
        end

        def deep_state
          if collection?
            {}.tap do |result|
              each_component do |component|
                result[component.collection_key] = component.deep_state
              end
            end
          else
            component.deep_state
          end
        end

        def collection?
          factory.enum?
        end

        def content
          if collection?
            @components
          else
            @components.first
          end
        end

        def component (index = 0)
          @components[index]
        end

        def each_component (&block)
          @components.each_with_index do |component, index|
            with_component(index, &block)
          end
        end

        def with_component (index, retry_on_error: false, &block)
          yield @components[index]
        rescue StandardError => error
          App::Logger.exception(@parent, error)
          @components[index] = ErrorPage.new({}, error: error, collection_index: index)
          yield @components[index] if retry_on_error
        end

        def append (model)
          build(model, @components.length).tap do |subcomponent|
            parent.delta.append(subcomponent, to: collection_selector)
          end
        end

        def prepend (model)
          build(model, 0).tap do |subcomponent|
            parent.delta.prepend(subcomponent, to: collection_selector)
          end
        end

        def remove (collection_key)
          parent.delta.remove(
             Component::Base.element_id(
                parent.path.concat("#{name}-#{collection_key}")
             )
          )
        end

        def collection_selector
          "." + parent.collection_classname(@name)
        end

        def on_route?
          @parent.routes_to?(self)
        end

        private

        def factory
          normalize_binding(@field.value)
        end

        def build (element, index)
          factory.call({}, nil, @parent, @name, @ordinal,
             element: element, collection_index: index)
        end

        #
        # If a nest block returned a component class instead of a Factory,
        # then wrap that class in a Factory.
        # 
        def normalize_binding (binding)
          case binding
          when Factory then binding
          when -> (k) { k <= Component::Base } then Factory.new(binding)
          else raise ArgumentError, "Invalid Factory: #{binding.class}"
          end
        end
      end

      #
      # Dynamically selects the component class to instantiate based on the
      # block passed to the nest method.
      # 
      class DynamicNest < Nest
        def initialize (parent, name, &block)
          super(name, parent)
          @field = Field.new(@parent, &block)
          @field.attach(self) do
            unless builder.component_class == @component.class
              install(@parent.send :nested_state, @name)
            end
          end
        end

        def install (state)
          @component = builder.call(state, @parent, @name)
        rescue StandardError => error
          @component = ErrorPage.new({}, error: error)
        end

        def builder
          @parent.class.builders.fetch(@field.value) do
            raise ArgumentError, "No builder for nested component: #{@field.value}"
          end
        end

        def content
          @component
        end
      end

      #
      # Instantiates a subcomponent of the given class, passing in signals
      # from the parent component.
      # 
      class StaticNest < Nest
        def initialize (parent, name, klass, *signals, **signal_map)
          super(name, parent)
          @klass      = Types.subclass(Component::Base)[klass]
          @signal_map = SignalMap.new(*signals, **signal_map)
        end

        def install (state)
          @component = builder.call(state, @parent, @name)
        rescue StandardError => error
          @component = ErrorPage.new({}, error: error)
        end

        def builder
          Builder.new(@klass, @signal_map)
        end

        def with_component (index = :ignored, retry_on_error: false, &block)
          block.call(@component)
        rescue StandardError => error
          App::Logger.exception(@parent, error)
          @component = ErrorPage.new({}, error: error)
          block.call(@component) if retry_on_error
        end

        def content
          @component
        end

        def deep_state
          @component.deep_state
        end
      end
    end
  end
end