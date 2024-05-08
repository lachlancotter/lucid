module Lucid
  #
  # Configure render settings for a component.
  #
  class ChangeSet
    extend Forwardable

    def initialize (component, wrapper_attrs = {})
      @component     = Check[component].type(Component::Base).value
      @wrapper_attrs = Check[wrapper_attrs].hash.value
      @changes       = []
    end

    attr_reader :component, :changes
    def_delegators :@changes, :empty?, :any?, :count, :first, :map
    def_delegators :@component, :element_id

    def replace (template_name = Rendering::DEFAULT_TEMPLATE)
      tap { @changes = [Replace.new(@component, template_name)] }
    end

    def append (subcomponent)
      tap { add_change Append.new(subcomponent, to: @component) }
    end

    def prepend (subcomponent)
      tap { add_change Prepend.new(subcomponent, to: @component) }
    end

    def to_s
      @changes.map(&:call).join
    end

    def add_change (change)
      @changes << change unless @changes.any? { |c| c.is_a?(Replace) }
    end

    #
    # Return a minimal list of components that need to be rendered.
    #
    def branches (list = [])
      list.tap do
        if any?
          list << self
        else
          @component.subcomponents.each do |(name, sub)|
            sub.changes.branches(list)
          end
        end
      end
    end

    #
    # A change to be applied to a component.
    #
    # class Change
    #   def initialize (component)
    #     @component = Check[component].type(Component::Base).value
    #   end
    # end

    #
    # Entirely replace the content of the element.
    #
    class Replace
      def initialize (component, template_name = Rendering::DEFAULT_TEMPLATE)
        @component = Check[component].type(Component::Base).value
        @template  = @component.template(template_name)
      end

      def call (wrapper_attrs = {})
        wrapper(wrapper_attrs).wrap { @template.render(*args) }
      end

      private

      def wrapper (attrs)
        Template::Wrapper.new(@component, attrs)
      end

      #
      # In a replace operation, args are bound to the component's fields.
      #
      def args
        @template.parameters.map do |(type, name)|
          @component.field(name).value
        end
      end
    end

    #
    # Prepend a template as the first child of the element.
    #
    class Prepend
      def initialize (component, to:)
        @component = Check[component].type(Component::Base).value
        @parent    = Check[to].type(Component::Base).value
        @template  = @component.template
      end

      def call
        wrapper.wrap { @template.render(*args) }
      end

      def wrapper
        Template::Wrapper.new(@component, wrapper_attrs)
      end

      def wrapper_attrs
        HTMX.oob(afterbegin: @parent.element_id).merge(id: @component.element_id)
      end

      def args
        @template.parameters.map do |(type, name)|
          @component.field(name).value
        end
      end
    end

    #
    # Append a template as the last child of the element.
    #
    class Append
      def initialize (component, to:)
        @component = Check[component].type(Component::Base).value
        @parent    = Check[to].type(Component::Base).value
        @template  = @component.template
      end

      def call
        wrapper.wrap { @template.render(*args) }
      end

      def wrapper
        Template::Wrapper.new(@component, wrapper_attrs)
      end

      def wrapper_attrs
        HTMX.oob(beforeend: @parent.element_id).merge(id: @component.element_id)
      end

      def args
        @template.parameters.map do |(type, name)|
          @component.field(name).value
        end
      end
    end

  end
end