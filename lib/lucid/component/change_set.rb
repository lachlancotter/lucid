module Lucid
  module Component
    #
    # Configure render settings for a component.
    #
    class ChangeSet
      extend Forwardable

      def initialize (component)
        @component = Check[component].type(Component::Base).value
        @changes   = []
      end

      attr_reader :component, :changes
      def_delegators :@changes, :empty?, :any?, :count, :first, :map, :[], :each
      def_delegators :@component, :element_id

      def replace?
        any? { |change| change.is_a?(Replace) }
      end

      def replace
        tap { @changes = [Replace.new(@component)] }
      end

      def append (subcomponent, to: "")
        selector = [@component.element_id, to].reject(&:empty?).join(" ")
        tap { add_change Append.new(subcomponent, to: selector) }
      end

      def prepend (subcomponent)
        tap { add_change Prepend.new(subcomponent, to: @component) }
      end

      def add_change (change)
        @changes << change unless replace?
      end

      #
      # Build a list of changes to apply for this an any nested components.
      #
      class Branches
        extend Forwardable

        def initialize
          @changes = []
        end

        def_delegators :@changes, :empty?, :any?, :count, :first, :map, :[], :each

        def [] (index)
          @changes[index].call(oob: index > 0)
        end

        def to_s
          0.upto(@changes.count - 1).map { |index| self[index] }.join
        end

        def primary_target
          return "" if @changes.empty?
          "#" + @changes.first.target
        end

        def primary_swap
          return "none" if @changes.empty?
          @changes.first.swap.to_s
        end

        def append_component (component)
          Check[component].type(Component::Base)
          append_change_set(component.delta)
          append_children(component) unless component.delta.replace?
        end

        def append_change_set (change_set)
          change_set.each { |change| @changes << change }
        end

        def append_children (component)
          component.subcomponents.each do |(name, sub)|
            Match.on(sub) do
              type(Component::Base) { |sub| append_component(sub) }
              type(Enumerable) { |enum| append_collection(enum) }
            end
          end
        end

        def append_collection (collection)
          collection.each { |subcomponent| append_component(subcomponent) }
        end
      end

      #
      # A change to be applied to a component.
      #
      class Change
        def initialize (component)
          @component = Check[component].type(Component::Base).value
          @template  = @component.template
        end

        attr_reader :component

        def call (oob: false)
          wrap(oob: oob) { @template.render(*args) }
        end

        private

        def wrap (oob:, &block)
          HTML::Template::Wrapper.new(@component, wrapper_attrs(oob: oob)).wrap(&block)
        end

        def wrapper_attrs (oob:)
          { id: @component.element_id }
        end

        def args
          @template.parameters.map do |(type, name)|
            @component.field(name).value
          end
        end
      end

      #
      # Entirely replace the content of the element.
      #
      class Replace < Change
        def initialize (component)
          super(component)
          @template = @component.template
        end

        def swap
          :outerHTML
        end

        def target
          @component.element_id
        end

        private

        def wrapper_attrs (oob:)
          super.merge(oob ? HTMX.oob(swap => target) : {})
        end
      end

      #
      # Prepend a template as the first child of the element.
      #
      class Prepend < Change
        def initialize (component, to:)
          super(component)
          @parent = Check[to].type(Component::Base).value
        end

        def swap
          :afterbegin
        end

        private

        def wrapper_attrs (oob:)
          super.merge(oob ? HTMX.oob(swap => @parent.element_id) : {})
        end
      end

      #
      # Append a template as the last child of the element.
      #
      class Append < Change
        def initialize (component, to:)
          super(component)
          @selector = to
        end

        def swap
          :beforeend
        end

        def target
          @selector
        end

        private

        def wrapper_attrs (oob:)
          super.merge(oob ? HTMX.oob(swap => target) : {})
        end
      end

    end
  end
end