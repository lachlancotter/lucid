module Lucid
  class EventHandler
    def initialize (event_class, &block)
      @event_class = event_class
      @block       = block
    end

    def handles?(event)
      event.is_a?(@event_class)
    end

    def call (event, view)
      @block.call(event, view.state)
    end
  end
end