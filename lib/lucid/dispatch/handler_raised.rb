module Lucid
  #
  # Dispatched when a handler raises an error.
  # 
  class HandlerRaised < Event
    validate do
      required(:error).filled
    end
  end
end