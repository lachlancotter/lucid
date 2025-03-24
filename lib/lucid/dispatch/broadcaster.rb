module Lucid
  #
  # Notifies the application of events.
  #
  class Broadcaster
    def initialize (handler_root, container = nil)
      @handler_root = handler_root
      @container    = container
      # @app = app
    end

    def publish (event)
      Logger.event(event)
      # @app.notify(event)
    end
  end
end