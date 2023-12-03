module Lucid
  #
  # Notifies the application of events.
  #
  class EventBus
    def initialize (app)
      @app = app
    end

    def notify (event)
      Logger.event(event)
      @app.notify(event)
    end
  end
end