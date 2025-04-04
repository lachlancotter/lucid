module Lucid
  module State
    #
    # Shared base class for buffers. Maintain a stack of
    # parameter scopes.
    #
    class Stack
      def initialize (top = {})
        @scope = [Types.hash[top]]
      end

      def top
        @scope.last
      end

      def base
        @scope.first
      end

      def push_scope (key)
        Types.symbol[key]
        @scope.last[key] = {} unless @scope.last.key?(key)
        @scope.push(@scope.last[key]).tap { Types.hash[@scope.last] }
      end

      def pop_scope
        Underflow.check(@scope)
        @scope.pop
        # If no params were added to the scope, remove it.
        @scope.last.delete_if { |k, v| v.is_a?(Hash) && v.empty? }
      end

      def with_scope (key, &block)
        push_scope(key)
        yield
        pop_scope
      end
      
      class Underflow < StandardError
        def initialize
          super("Attempt to pop the last scope from the stack. Probably a bug.")
        end
        
        def self.check (scope)
          raise new if scope.length == 1
        end
      end
    end
  end
end