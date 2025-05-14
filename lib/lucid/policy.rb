module Lucid
  #
  # Base class for access policies which define when a handler or component
  # can be called.
  # 
  class Policy
    def initialize (context)
      @context = context
    end

    def apply (message, context = @context, &block)
      context.instance_exec(message, &block) if permits_message?(message)
    end

    def permits_message? (message)
      raise NotImplemented, :permits_message?
    end

    def permits_view? (resource)
      raise NotImplemented, :permits_view?
    end

    #
    # DSL to define resource dependencies for the policy.
    # 
    class << self
      def use (accessor_name)
        define_method(accessor_name) do |*args, &block|
          @context.send(accessor_name, *args, &block)
        end
      end
    end

    #
    # Default policy that permits all messages and views.
    # 
    class PublicPolicy < Policy
      def permits_message? (message)
        true
      end

      def permits_view? (resource)
        true
      end
    end

    #
    # Subclasses must define the policy methods.
    # 
    class NotImplemented < StandardError
      def initialize (method_name)
        super("Subclass must implement the #{method_name} method")
      end
    end

  end
end