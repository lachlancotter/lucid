module Lucid
  module RSpec
    module Handlers
      #
      # Produce and approval file describing the handler effects.
      # 
      class HandlerReport < RSpecExtensions::Approvals::DB::Report
        def initialize (message, message_bus, database_observer)
          @message     = message
          @message_bus = message_bus
          super(database_observer)
        end

        def report_sections
          [message, published, summary, creates, updates]
        end

        def message
          {
             "message" => format_message(@message)
          }
        end

        def published
          {
             "published" => @message_bus.messages.map do |message|
               format_message(message)
             end
          }
        end

        def format_message (message)
          {
             "type"    => message.class.name,
             "payload" => message.to_h
          }
        end
      end

    end
  end
end