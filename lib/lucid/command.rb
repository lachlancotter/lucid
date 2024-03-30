module Lucid
  class Command < Message
    def http_method
      Message::POST
    end
  end
end