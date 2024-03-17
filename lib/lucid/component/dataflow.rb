module Lucid
  module Component
    module Dataflow
      def self.included(base)
        base.extend(ClassMethods)
      end

      #
      # Update a value in the state, and trigger invalidation of
      # dependent fields.
      #
      def update (data)
        @state.update(data)
        data.keys.map { |key| field(key) }.each(&:notify)
      end

      def field (name)
        @fields       ||= {}
        @fields[name] ||= Field.new(self, name)
      end

      def field? (name)
        return true if self.class.state_class.attributes.include?(name)
        return true if (self.class.instance_variable_get(:@lets) || []).include?(name)
        false
      end

      # def lets
      #   self.class.instance_variable_get(:@lets).each { |name| send(name) }
      #   @lets
      # end

      module ClassMethods
        #
        # Define a dependent field that is calculated from the specified
        # dependent values. The block is evaluated in the context of the
        # component instance.
        #
        def let (name, &block)
          @lets ||= []
          @lets << name
          define_method(name) do
            @lets       ||= {}
            @lets[name] ||= Let.new(self, name, &block)
            @lets[name].value
          end
        end

        #
        # Declare a dependency on a field defined in a parent component.
        #
        def use (name)
          define_method(name) do
            current = config.parent
            while current
              if current.field?(name)
                return current.send(name)
              else
                current = current.config.parent
              end
            end
            raise Field::NoSuchField.new(name)
          end
        end
      end

      #
      # An interface over state variables and dependent fields that
      # provides a consistent way to access and observe changing values.
      #
      class Field
        include Observable

        class NoSuchField < ArgumentError
          def initialize (name)
            super("No such field: #{name}")
          end
        end

        def initialize (context, name)
          @context = context
          @name    = name
        end
      end

      #
      # Encapsulates a dependent field that is calculated from other
      # changing values, named as parameters of the block.
      #
      class Let
        def initialize (context, name, &block)
          @context   = context
          @name      = name
          @block     = block
          @value     = nil
          @evaluated = false
          params.each do |param|
            @context.field(param).attach(self) { invalidate }
          end
        end

        def value
          unless @evaluated
            @value     = @block.call(*args)
            @evaluated = true
          end
          @value
        end

        def invalidate
          @evaluated = false
          @context.field(@name).notify
        end

        private

        def params
          @block.parameters.map { |param| param[1] }
        end

        def args
          params.map { |param| @context.send(param) }
        end
      end

    end
  end
end