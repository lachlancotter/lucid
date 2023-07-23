require "lucid/event_bus"

module Lucid
  #
  # Runs an event cycle for an application.
  #
  class Controller
    def initialize (app_class, app_root)
      @app_class = app_class
      @app_root  = app_root
    end

    attr_reader :app

    def call (params)
      action_path = params.delete("action")
      @app        = build(params)
      with_bus do
        @app.perform_action(action_path, params) unless action_path.nil?
        @app.to_s
      end
    end

    def with_bus (&block)
      old_bus          = Lucid::Event.bus
      Lucid::Event.bus = EventBus.new(@app)
      block.call
    ensure
      Lucid::Event.bus = old_bus
    end

    def build (params)
      @app_class.new(params) do |config|
        config.app_root = @app_root
      end
    end
  end
end