module Lucid
  #
  # Notifies the application of events.
  #
  class EventBus
    def initialize (app)
      @app = app
    end

    def notify (event)
      puts "EventBus#notify: #{event.data.to_h}"
      @app.event_handlers.each do |handler|
        if handler.handles?(event)
          handler.call(event, @app)
        end
      end
    end
  end
end