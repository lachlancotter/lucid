module Lucid
  module Component
    #
    # Manages changes applied to a tree of components.
    #
    class ChangeSet
      extend Forwardable

      def initialize (component)
        @component = Types.component[component]
        @changes   = []
      end

      attr_reader :component, :changes
      def_delegators :@changes, :empty?, :any?, :count, :first, :map, :[], :each
      def_delegators :@component, :element_id

      def replace?
        any? { |change| change.is_a?(Replace) }
      end
      
      def delete?
        any? { |change| change.is_a?(Delete) }
      end

      def replace
        # Replacing a component makes any other changes irrelevant.
        # Except the case where the component is deleted. Then the
        # replace update is discarded.
        tap { @changes = [Replace.new(@component)] unless delete? }
      end
      
      def delete
        # If a component is deleted, that overrides any other updates.
        tap { @changes = [Delete.new(@component)] }
      end

      def append (subcomponent, to: "")
        tap { add_change Append.new(subcomponent, to: selector(nest: to)) }
      end

      def prepend (subcomponent, to: "")
        tap { add_change Prepend.new(subcomponent, to: selector(nest: to)) }
      end
      
      def remove (subcomponent)
        tap { subcomponent.delta.delete }
      end
      
      def selector (nest: "")
        [@component.element_id, nest].reject(&:empty?).join(" ")
      end

      def add_change (change)
        @changes << change unless replace? || delete?
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
          Types.component[component]
          append_change_set(component.delta)
          append_children(component) unless component.delta.replace?
        end

        def append_change_set (change_set)
          change_set.each { |change| @changes << change }
        end

        def append_children (component)
          component.subcomponents.each do |(name, sub)|
            case sub
            when Component::Base then append_component(sub)
            when Component::Nesting::Collection then append_collection(sub)
            else raise ArgumentError, "Unsupported subcomponent type: #{sub.class}"
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
          @component = Types.component[component]
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
      # Delete the component element from the DOM.
      # 
      class Delete < Change
        def initialize (component)
          super(component)
        end

        def call (oob: false)
          wrap(oob: oob) { "" }
        end

        def swap
          :delete
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
      # Insert items into a collection.
      # 
      class CollectionChange < Change
        def initialize (component, to:)
          super(component)
          @selector = to
        end

        def target
          @selector
        end

        private

        def wrapper_attrs (oob:)
          super.merge(oob ? HTMX.oob(swap => target) : {})
        end
      end

      #
      # Prepend a template as the first child of the element.
      #
      class Prepend < CollectionChange
        def swap
          :afterbegin
        end
      end

      #
      # Append a template as the last child of the element.
      #
      class Append < CollectionChange
        def swap
          :beforeend
        end
      end
    end
  end
end