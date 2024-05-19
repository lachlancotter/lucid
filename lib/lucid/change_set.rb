module Lucid
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
      any? { |c| c.is_a?(Replace) }
    end

    def replace (template_name = Rendering::DEFAULT_TEMPLATE)
      tap { @changes = [Replace.new(@component, template_name)] }
    end

    def append (subcomponent)
      tap { add_change Append.new(subcomponent, to: @component) }
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
        "#" + @changes.first.component.element_id
      end

      def append_component (component)
        Check[component].type(Component::Base)
        append_change_set(component.element)
        append_children(component) unless component.element.replace?
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
        Template::Wrapper.new(@component, wrapper_attrs(oob: oob)).wrap(&block)
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
      def initialize (component, template_name = Rendering::DEFAULT_TEMPLATE)
        super(component)
        @template = @component.template(template_name)
      end

      private

      def wrapper_attrs (oob:)
        super.merge(oob ? HTMX.oob(innerHTML: @component.element_id) : {})
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

      private

      def wrapper_attrs (oob:)
        super.merge(oob ? HTMX.oob(afterbegin: @parent.element_id) : {})
      end
    end

    #
    # Append a template as the last child of the element.
    #
    class Append < Change
      def initialize (component, to:)
        super(component)
        @parent = Check[to].type(Component::Base).value
      end

      private

      def wrapper_attrs (oob:)
        super.merge(oob ? HTMX.oob(beforeend: @parent.element_id) : {})
      end
    end

  end
end