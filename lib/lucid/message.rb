require "lucid/http/message_name"

module Lucid
  class Message < OpenStruct
    def message_name
      HTTP::MessageName.encode(self.class)
    end
  end
end