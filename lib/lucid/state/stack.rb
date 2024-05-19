module Lucid
  module State
    #
    # Shared base class for buffers. Maintain a stack of
    # parameter scopes.
    #
    class Stack


      def initialize (top = {})
        @scope = [Check[top].hash.value]
      end

      def top
        @scope.last
      end

      def base
        @scope.first
      end

      def push_scope (key)
        Check[key].symbol.value
        @scope.last[key] = {} unless @scope.last.key?(key)
        @scope.push(@scope.last[key]).tap { Check[@scope.last].hash }
      end

      def pop_scope
        Check[@scope.length].gt(1, "underflow")
        @scope.pop
        # If no params were added to the scope, remove it.
        @scope.last.delete_if do |k, v|
          v.is_a?(Hash) && v.empty?
        end
      end

      def with_scope (key, &block)
        push_scope(key)
        yield
        pop_scope
      end
    end
  end
end