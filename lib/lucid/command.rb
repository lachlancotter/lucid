require "lucid/message"
require "lucid/html/button"
require "lucid/html/form"

module Lucid
  class Command < Message
    def http_method
      Message::POST
    end
  end
end