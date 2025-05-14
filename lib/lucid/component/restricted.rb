module Lucid
  module Component
    #
    # Enables Components to adopt policies to restrict access.
    # 
    module Restricted
      def self.included(base)
        base.extend(ClassMethods)
        base.after_build do
          raise PermissionError.new(self) if denied?
        end
      end

      def denied?
        !permitted?
      end

      def permitted?
        policy.permits_view?
      end

      # Override policy with the adopt method.
      def policy
        @policy_context ||= PolicyContext.new(
           Policy::PublicPolicy.new(self), nil, self
        )
      end

      #
      # DSL.
      # 
      module ClassMethods
        def adopt (policy_class, resource_name)
          define_method(:policy) do
            @policy_context ||= PolicyContext.new(
               policy_class.new(self), resource_name, self
            )
          end
        end
      end

      #
      # Wrapper around a Policy object that retains the context of the
      # Component and the resource name.
      # 
      class PolicyContext
        def initialize (policy, resource_name, context)
          @policy        = policy
          @resource_name = resource_name
          @context       = context
        end

        def permits_view?
          @policy.permits_view?(resource)
        end

        def resource
          @resource_name.nil? ? nil : @context.send(@resource_name)
        end
      end
    end
  end
end