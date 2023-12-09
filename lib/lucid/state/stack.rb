module Lucid
  module State
    #
    # Shared base class for buffers. Maintain a stack of
    # parameter scopes.
    #
    class Stack
      def initialize (top = {})
        @scope = [top]
      end

      def top
        @scope.last
      end

      def push_scope (key)
        @scope.last[key] = {} unless @scope.last.key?(key)
        @scope << @scope.last[key]
      end

      def pop_scope
        raise "scope underflow" if @scope.length == 1
        @scope.pop
        # If no params were added to the scope, remove it.
        @scope.last.delete_if { |k, v| v.empty? }
      end

      def with_scope (key, &block)
        push_scope(key)
        yield
        pop_scope
      end
    end
  end
end