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
      tap { @changes = [Replace.new(@component, template_name, @wrapper_attrs)] }
    end

    def append (template_name, *template_args)
      tap { add_change Append.new(@component, template_name, *template_args) }
    end

    def prepend (template_name, *template_args)
      tap { add_change Prepend.new(@component, template_name, *template_args) }
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
  end

  #
  # A change to be applied to a component.
  #
  class Change
    def initialize (component, template_name, *template_args)
      @component     = component
      @template_name = template_name
      @template_args = template_args
    end

    def template
      @component.template(@template_name)
    end
  end

  #
  # Entirely replace the content of the element.
  #
  class Replace < Change
    def initialize (component, template_name, wrapper_attrs)
      super(component, template_name)
      @wrapper_attrs = Check[wrapper_attrs].hash.value
    end

    def call
      wrapper.wrap { template.render(*args) }
    end

    private

    def wrapper
      Template::Wrapper.new(@component, @wrapper_attrs)
    end

    #
    # In a replace operation, args are bound to the component's fields.
    #
    def args
      template.parameters.map do |(type, name)|
        @component.field(name).value
      end
    end
  end

  #
  # Prepend a template as the first child of the element.
  #
  class Prepend < Change
    def call
      template.render(*args)
    end

    def args
      @template_args
    end
  end

  #
  # Append a template as the last child of the element.
  #
  class Append < Change
    def call
      template.render(*args)
    end

    def args
      @template_args
    end
  end

end