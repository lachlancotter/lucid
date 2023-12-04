module Lucid
  module Validation
    class Result < Event
      attribute :message
      validate do
        required(:message)
      end
    end

    class Failed < Result

    end

    class Passed < Result

    end
  end
end