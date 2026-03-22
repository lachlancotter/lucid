module Lucid
  module RSpec
    module Handlers
      
      #
      # Store messages so they can be verified in the test.
      # 
      class FakeMessageBus
        def initialize
          @messages = []
        end

        def publish(message)
          @messages << message
        end

        def dispatch(message)
          @messages << message
        end

        def messages
          @messages
        end

        def clear_messages
          @messages.clear
        end
      end

    end
  end
end