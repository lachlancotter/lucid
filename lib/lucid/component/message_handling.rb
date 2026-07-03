module Lucid
  module Component
    module MessageHandling
      def message_handlers
        @message_handlers ||= MessageHandlers.new
      end
    end
  end
end
