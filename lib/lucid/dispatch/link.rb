module Lucid
  #
  # Represents a state in the information space that a user
  # can visit.
  #
  class Link < HTTP::Message

    def self.http_method
      HTTP::Message::GET
    end

    def key
      self.class
    end

  end
end
