module Lucid
  #
  # Notifies the application of events.
  #
  class EventBus
    def initialize (app)
      @app = app
    end

    def notify (event)
      @app.event_handlers.each do |handler|
        if handler.handles?(event)
          handler.call(event, @app)
        end
      end
    end
  end
end