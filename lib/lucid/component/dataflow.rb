module Lucid
  module Component
    module Dataflow
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def let(name, &block)
          define_method(name) do
            @lets ||= {}
            @lets[name] ||= Let.new(self, &block)
            @lets[name].value
          end
        end
      end

      class Let
        include Observable::Observer

        def initialize (scope, &block)
          @scope = scope
          @block = block
          @value = nil
          @evaluated = false
          @scope.state.attach(self, *params)
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
        end

        def update (subject, key, value)
          invalidate
        end

        private

        def params
          @block.parameters.map { |param| param[1] }
        end

        def args
          params.map { |param| @scope.send(param) }
        end
      end

    end
  end
end