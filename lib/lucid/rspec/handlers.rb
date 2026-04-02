module Lucid
  module RSpec
    module Handlers
      #
      # Specify that a handler adopts a policy class.
      # 
      if defined?(::RSpec)
        ::RSpec::Matchers.define :adopt_policy do |policy_class|
          match do |handler_class|
            instantiate(handler_class).policy.class == policy_class
          end

          failure_message do |actual|
            "expected #{actual} to adopt #{policy_class}, but it's actual policy is #{instantiate(actual).policy}"
          end

          failure_message_when_negated do |actual|
            "expected #{actual} not to adopt #{policy_class}, but it does"
          end

          description do
            "adopt #{policy_class}"
          end

          def instantiate (handler_class)
            @handler_instance ||= begin
              message = double("Message")
              handler_class.new(message, container)
            end
          end
        end
      end
    end
  end
end
