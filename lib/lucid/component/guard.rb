module Lucid
  module Component
    #
    # Encapsulates a guard predicate that returns Permit or Deny.
    #
    class Guard
      def initialize (&block)
        @block = block
      end

      attr_reader :block

      def bind (context)
        Binding.new(self, context)
      end

      #
      # Provides the execution context for the guard condition.
      # 
      class Binding
        def initialize (guard, context)
          @field = Field.new(context, &guard.block)
        end

        def call
          @field.value.tap do |result|
            raise Invalid.new(result) unless result.is_a?(Result)
          end
        end

        def denied?
          call.denied?
        end

        def permitted?
          call.permitted?
        end

        def if_denied (&block)
          call.if_denied(&block)
        end

        def if_permitted (&block)
          call.if_permitted(&block)
        end
      end

      #
      # The result of a guard condition is invalid.
      #
      class Invalid < StandardError
        def initialize (result)
          super("Guard condition must evaluate to Permit or Deny; result: #{result.inspect}")
        end
      end

      #
      # Attempt to render a component when access is denied.
      #
      class Violation < StandardError
        def initialize (message)
          super("Guard condition violated: #{message}")
        end
      end

      #
      # Guard conditions must return an instance of Result (either Permit or Deny).
      #
      class Result
        #
        # Constructor syntax sugar.
        #
        def self.[] (*args)
          new(*args)
        end

        def initialize(*args)
          @args = args
        end

        attr_reader :detail
      end

      #
      # The guard condition permits access to the component.
      #
      class Permit < Result
        def permitted?
          true
        end

        def denied?
          false
        end

        def if_permitted
          yield(self)
        end

        def if_denied
          nil
        end
      end

      #
      # The guard condition denies access to the component.
      #
      class Deny < Result
        def permitted?
          false
        end

        def denied?
          true
        end

        def if_permitted
          nil
        end

        def if_denied
          yield(self)
        end
      end
    end
  end

  #
  # Export the Permit and Deny constants for convenient use in guard conditions.
  #
  Permit = Component::Guard::Permit.new.freeze
  Deny   = Component::Guard::Deny.new.freeze
end