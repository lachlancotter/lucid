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

      def subcomponent (name, index = nil)
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
        # block - Function returning a PropsBinding instance for building the component.
        # 
        def nest (name, over: nil, &block)
          after_application do
            nests[name] = case over
            when Symbol then CollectionNest.new(name, self, over, &block)
            when Enumerable then CollectionNest.new(name, self, over, &block)
            when NilClass then ComponentNest.new(name, self, &block)
            else raise ArgumentError, "Invalid enumerable"
            end
            # Refactor so that @message is yielded to the callback block.
            nests[name].install(nested_state(name), @message)
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
      #    PropsBinding
      # ===================================================== #

      #
      # A partial configuration for a component that can be used to build
      # the component instance when the state is available. Instances of 
      # this class are returned by the `[]` class method on Component as
      # a kind of factory for nested components.
      # 
      class PropsBinding
        attr_reader :component_class

        def initialize (component_class, *list, **map)
          @component_class = Types.subclass(Component::Base)[component_class]
          @signal_map      = SignalMap.new(*list, **map)
        end

        def call (state, message, parent, name, collection_index: nil)
          Types.instance(Message).optional[message]
          @component_class.new(state, message, **build_props(parent, name, collection_index))
        end

        # def update (component)
        #   if component.is_a?(@component_class)
        #     component.update_props(@props)
        #   end
        # end

        private

        def build_props (parent, name, collection_index)
          config(parent, name, collection_index).merge(
             @signal_map.apply(parent, index: collection_index)
          )
        end

        def config (parent, name, collection_index)
          {
             parent:           parent,
             name:             name,
             collection_index: collection_index,
             app_root:         parent.props.app_root,
             session:          parent.props.session,
             container:        parent.props.container,
          }
        end
      end

      # ===================================================== #
      #    Nest
      # ===================================================== #

      #
      # Abstract base class for nesting subcomponents.
      # 
      class Nest
        attr_reader :parent, :name

        def initialize (name, parent)
          @parent = parent
          @name   = name
        end

        #
        # If a nest block returned a component class instead of a PropsBinding,
        # then wrap that class in a PropsBinding.
        # 
        def normalize_binding (binding)
          case binding
          when PropsBinding then binding
          when -> (k) { k <= Component::Base } then PropsBinding.new(binding)
          else raise ArgumentError, "Invalid PropsBinding: #{binding.class}"
          end
        end

        def on_route?
          @parent.routes_to?(self)
        end
      end

      #
      # Map a list of component fields to the fields in a parent component, 
      # so they can be passed by reference to a nested component.
      # 
      class SignalMap
        def initialize (*list, **map)
          @list = Types.array(Types.symbol)[list]
          @map  = Types.hash[map]
        end

        def apply (component, index: nil)
          Hash[
             @list.map do |name|
               [name, component.field(name)]
             end + @map.map do |dest, source|
               [dest, signal(component, source, index)]
             end
          ]
        end

        def signal (component, source, index)
          case source
          when Symbol then component.field(source)
          when Array then element(component, source.first, index)
          else literal(component, source)
          end
        end

        def literal (component, value)
          Field.new(component) { value }
        end

        def element (component, source, index)
          Field.new(component) { component.field(source).value[index] }
        end
      end

      #
      # Instantiates and configures a nested component.
      # 
      class Builder
        def initialize (klass, signal_map)
          @component_class = Types.subclass(Component::Base)[klass]
          @signal_map      = signal_map
        end

        attr_reader :component_class

        def call (state, parent, name)
          props_binding(parent).call(state, parent, name)
        end

        def props_binding (parent)
          PropsBinding.new(@component_class, **@signal_map.apply(parent))
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
          App::Logger.exception(error)
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

      #
      # Housing for an individual subcomponent.
      # 
      class ComponentNest < Nest
        def initialize (name, parent, &block)
          super(name, parent)
          @field = Field.new(@parent, &block)
          @field.attach(self) { update }
        end

        def content
          @component
        end

        def component (index = :ignored)
          @component
        end

        def each_component (&block)
          with_component(&block)
        end

        def with_component (index = :ignored, retry_on_error: false, &block)
          block.call(@component)
        rescue StandardError => error
          App::Logger.exception(error)
          @component = ErrorPage.new({}, error: error)
          block.call(@component) if retry_on_error
        end

        def deep_state
          @component.deep_state
        end

        def collection?
          false
        end

        def install (state, message)
          props_binding.tap do |binding|
            @component = binding.call(state, message, @parent, @name)
          end
        rescue StandardError => error
          App::Logger.exception(error)
          @component = ErrorPage.new({}, error: error)
        end

        def update
          props_binding.tap do |binding|
            unless @component.is_a?(binding.component_class)
              # Should we propagate the state to the new component here; or reset it?
              @component = binding.call(@component.state.to_h, nil, @parent, @name)
              @component.delta.replace
            end
          end
        rescue StandardError => error
          @component = ErrorPage.new({}, error: error, parent: @parent, name: @name)
          @component.delta.replace
        end

        def props_binding
          normalize_binding(@field.value)
        end
      end

      #
      # Housing for a collection of subcomponents mapped over an Enumerable.
      # 
      class CollectionNest < Nest
        def initialize (name, parent, over, &block)
          super(name, parent)
          @enumerable = case over
          when Symbol then parent.field(over).value
          when Enumerable then over # Static collection
          else raise ArgumentError, "Unsupported collection nesting: #{over.class}"
          end
          @map_f      = block
          # Wrap the provided block in an enumerator function, and configure the
          # field to call it with the keywords expected by the mapping function.
          # So they can be passed through to the mapping function.
          enum_f = enumerator(@enumerable, self, name, parent)
          exec   = Field::Execution.new(enum_f).set_keywords(from_block: @map_f)
          @field = Field.new(@parent, exec)
        end

        def content
          Types.instance(Collection)[@collection]
        end

        def component (index)
          @collection[index]
        end

        def each_component (&block)
          @collection.each_with_index do |component, index|
            with_component(index, &block)
          end
        end

        def with_component (index, retry_on_error: false, &block)
          yield @collection[index]
        rescue StandardError => error
          App::Logger.exception(error)
          @collection[index] = ErrorPage.new({}, error: error, collection_index: index)
          yield @collection[index] if retry_on_error
        end

        def deep_state
          {}.tap do |result|
            each_component do |component|
              result[component.collection_key] = component.deep_state
            end
          end
        end

        def collection?
          true
        end

        def enumerator (enumerable, nest, name, parent)
          # This block will be run in the context of the parent component.
          proc do |**kwargs|
            enumerable.each_with_index.map do |element, index|
              begin
                props_binding = nest.props_binding(element, index, **kwargs)
                # nested_state() isn't implemented for collections.
                props_binding.call({}, nil, parent, name, collection_index: index)
              rescue StandardError => error
                App::Logger.exception(error)
                ErrorPage.new({}, error: error, collection_key: index)
              end
            end
          end
        end

        def install (state, message)
          # nested_state() isn't implemented for collections. so ignore the
          # state for now.
          @collection = Collection.new(self, @field.value)
        end

        def update
          raise "CollectionNest#update is not implemented"
        end

        # Build a single instance that can be used to render insertions.
        def build (element, index)
          # Look up any other expected keyword params in the parent component.
          params = Field::Execution.new(@map_f).keywords
          kwargs = params.map { |k| [k, @parent.field(k).value] }.to_h
          props_binding(element, index, **kwargs).call({}, nil, @parent, @name, collection_index: index)
        end

        def props_binding (element, index, **kwargs)
          normalize_binding(@parent.instance_exec(element, index, **kwargs, &@map_f))
        end
      end

      # ===================================================== #
      #    Collection
      # ===================================================== #

      #
      # An interface to access members of a nested component collection
      # and to make insertions into the collection, triggering updates
      # to the element ChangeSet.
      #
      class Collection
        include Enumerable

        def initialize (nest, elements)
          @nest     = Types.instance(Nest)[nest]
          @elements = Types.enumerable[elements]
        end

        def each (&block)
          @elements.each(&block)
        end

        def map! (&block)
          @elements.map!(&block)
        end

        def [] (key)
          @elements[key]
        end

        def []= (key, value)
          @elements[key] = value
        end

        def first
          @elements.first
        end

        def last
          @elements.last
        end

        # Build a new subcomponent and append it to the collection.
        def append (model)
          build(model).tap do |subcomponent|
            parent.delta.append(subcomponent, to: collection_selector)
          end
        end

        # Build a new subcomponent and prepend it to the collection.
        def prepend (model)
          build(model).tap do |subcomponent|
            parent.delta.prepend(subcomponent, to: collection_selector)
          end
        end

        # Remove subcomponents that match the given block.
        def remove (&block)
          each_with_index do |subcomponent, index|
            parent.delta.remove(subcomponent) if block.call(subcomponent, index)
          end
        end

        def collection_selector
          "." + parent.collection_classname(collection_name)
        end

        def collection_name
          Types.symbol[@nest.name]
        end

        private

        def build (model, index = @elements.size)
          @nest.build(model, index)
        end

        def parent
          @nest.parent
        end
      end

    end
  end
end