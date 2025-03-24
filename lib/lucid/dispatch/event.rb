module Lucid
  #
  # Base class for events.
  #
  class Event < Message
    extend Busable

    class << self
      def notify (data)
        new(data).notify
      end
    end

    def notify
      Event.bus.notify(self)
    end
  end
end