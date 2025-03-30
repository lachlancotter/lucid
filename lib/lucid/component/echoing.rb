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
          Types.Instance(Class)[message_class]
          variable = "@#{as}"

          after_initialize do
            fields[as] = Field.new(self) do
              if instance_variable_defined?(variable)
                instance_variable_get(variable)
              else
                default_params = instance_exec(&block)
                HTML::FormModel.new(message_class, default_params)
              end.tap do |result|
                Types.Instance(HTML::FormModel)[result]
              end
            end
          end

          on Lucid::Validation::Failed do |event|
            if event.message_type == message_class
              message_params = HTML::FormModel.new(event.message_type, event.message_params)
              instance_variable_set(variable, message_params)
            end
          end
        end
      end
    end
  end
end