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

      def subcomponents # Hash[Symbol => Component::Base | Enumerable]
        nests.map { |(name, nest)| [name, nest.content] }.to_h
      end

      def subcomponent (name, index = nil)
        nest = nests.fetch(name) { raise "No subcomponent named #{name}" }
        nest.collection? ? nest.collection[index] : nest.component
      end

      def each_subcomponent (&block)
        subcomponents.values.flatten.each do |sub|
          block.call(Types.component[sub])
        end
      end

      def nested_route_component
        subcomponent self.class.instance_variable_get(:@nested_route_component)
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
        # 
        # Defines a nested component.
        # name - The name of the nested component in the parent.
        # over - Name of an enumerable field to map over. Optional.
        # block - Function returning a PropsBinding instance for building the component.
        # 
        def nest (name, over: nil, &block)
          after_initialize do
            nests[name] = case over
            when Symbol then CollectionNest.new(name, self, over, &block)
            else ComponentNest.new(name, self, &block)
            end
            nests[name].install(nested_state(name))
          end
          define_method(name) { nests[name].content }
        end

        #
        # Defines a slot for a nested component provided as a prop.
        #
        def slot (name)
          prop name, Types.subclass(Component::Base)
          nest(name) { props[name] }
          watch(name) { nests[name].update_component(nested_state(name)) }
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

        def initialize (component_class, **props)
          @component_class = Types.subclass(Component::Base)[component_class]
          @props           = Types.hash[props]
        end

        def call (state, parent, name, is_collection_member: false)
          @component_class.new(state, **build_props(parent, name, is_collection_member))
        end

        def update (component)
          if component.is_a?(@component_class)
            component.update_props(@props)
          end
        end

        private

        def build_props (parent, name, is_collection_member)
          base_props(parent, name, is_collection_member).merge(@props)
        end

        def base_props (parent, name, is_collection_member)
          {
             parent:            parent,
             app_root:          parent.props.app_root,
             session:           parent.props.session,
             container:         parent.props.container,
             name:              name,
             collection_member: is_collection_member
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

        def rescue_errors (*error_classes, index: nil, retry_block: false, &block)
          yield content

          #   error_classes << StandardError unless error_classes.any?
          #   child_component = @over ? collection[index] : component
          #   block.call(child_component)
          # rescue *error_classes => error
          #   puts "#{error.class}: #{error.message}"
          #   puts error.backtrace.join("\n")
          #   replace_crashed_component(child_component, error)
          #   block.call(child_component) if retry_block
        end
      end

      #
      # Housing for an individual subcomponent.
      # 
      class ComponentNest < Nest
        def initialize (name, parent, &block)
          @name   = name
          @parent = parent
          @field  = Field.new(@parent, &block)
          @field.attach(self) { update }
        end

        def content
          @component
        end

        def install (state)
          props_binding.tap do |binding|
            @component = binding.call(state, @parent, @name)
          end
        end

        def update
          props_binding.tap do |binding|
            if @component.is_a?(binding.component_class)
              binding.update(@component)
            else
              # Should we propagate the state to the new component here; or reset it?
              @component = binding.call(@component.state.to_h, @parent, @name)
              @component.delta.replace
            end
          end
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
          @name       = name
          @parent     = parent
          @enumerable = parent.field(over).value
          @map_f      = block
          # Wrap the provided block in an enumerator function, and configure the
          # field to call it with the keywords expected by the mapping function.
          # So they can be passed through to the mapping function.
          enum_f = enumerator(self, name, parent, over)
          exec   = Field::Execution.new(enum_f).set_keywords(from_block: @map_f)
          @field = Field.new(@parent, exec)
        end

        def content
          @collection
        end

        def enumerator (nest, name, parent, over)
          # This block will be run in the context of the parent component.
          proc do |**kwargs|
            parent[over].each_with_index.map do |element, index|
              props_binding = nest.props_binding(element, index, **kwargs)
              # nested_state() isn't implemented for collections.
              props_binding.call({}, parent, name, is_collection_member: true)
            end
          end
        end

        def install (state)
          # nested_state() isn't implemented for collections. so ignore the
          # state for now.
          @collection = @field.value
        end

        def update
          raise "CollectionNest#update is not implemented"
        end

        # Build a single instance that can be used to render insertions.
        def build (element, index, **kwargs)
          props_binding(element, index, **kwargs).call({}, @parent, @name)
        end

        def props_binding (element, index, **kwargs)
          normalize_binding(@map_f.call(element, index, **kwargs))
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
          each do |subcomponent|
            parent.delta.remove(subcomponent) if block.call(subcomponent)
          end
        end

        def collection_selector
          "." + parent.collection_classname(collection_name)
        end

        def collection_name
          Types.symbol[@nest.name]
        end

        private

        def build (model)
          @nest.build(model)
        end

        def parent
          @nest.parent
        end
      end

      # ===================================================== #
      #    Error Handler
      # ===================================================== #

      class ErrorHandler
        #
        # If a component raises an exception (either during construction),
        # when applying a message, or when rendering, we consider that
        # component to be invalid and replace it with an error page.
        # 
        def replace_crashed_component (component, error)
          if @content && collection?
            replace_crashed_collection_item(component, error)
          else
            factory  = ErrorPage[error: error]
            @content = factory.build({}, @parent, name)
          end
        end

        def replace_crashed_collection_item (component, error)
          collection.map! do |sub|
            if sub == component
              factory = ErrorPage.enum([]) { { error: error } }
              index   = collection.index(component)
              factory.build_item(@parent, name, nil, index)
            else
              sub
            end
          end
        end
      end

    end
  end
end