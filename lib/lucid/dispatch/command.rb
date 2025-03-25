module Lucid
  class Command < HTTP::Message
    def self.http_method
      HTTP::Message::POST
    end
  end
end