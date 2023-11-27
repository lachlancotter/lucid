module Lucid
  #
  # Notifies the application of events.
  #
  class EventBus
    def initialize (app)
      @app = app
    end

    def notify (event)
      puts "EventBus#notify: #{event.class.name}"
      ap event.to_h
      @app.notify(event)
    end
  end
end