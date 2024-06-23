module Lucid
  module Validation
    class Result < Event
      validate do
        required(:message_type).filled(Types.Instance(Class))
        required(:message_params).filled(Types.hash)
      end
    end

    class Failed < Result

    end

    class Passed < Result

    end
  end
end