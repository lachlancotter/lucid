module Lucid
  class Command < HttpMessage
    def self.http_method
      HttpMessage::POST
    end
  end
end