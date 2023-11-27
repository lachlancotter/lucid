require "lucid/event"

module Lucid
  class ValidationFailed < Event
    # Message that failed validation.
    attribute :message
    validate do
      required(:message)
    end
  end
end