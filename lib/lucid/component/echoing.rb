module Lucid
  module Component
    #
    # Capture invalid messages so they can be echoed back to the client.
    #
    module Echoing
      def self.included (base)
        base.extend ClassMethods
      end

      module ClassMethods
        def echo (message_class, as:, &block)
          on Lucid::Validation::Failed do |event|
            if event.message.is_a?(message_class)
              instance_variable_set("@invalid_#{as}", event.message)
            end
          end

          define_method("#{as}_params") do
            if instance_variable_get("@invalid_#{as}")
              instance_variable_get("@invalid_#{as}").params
            else
              message_class.new(instance_exec(&block)).params
            end
          end

          define_method("#{as}_errors?") do
            !!instance_variable_get("@invalid_#{as}")
          end
        end
      end
    end
  end
end