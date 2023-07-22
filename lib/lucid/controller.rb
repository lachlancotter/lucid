module Lucid
  class Controller
    def initialize (app_class, app_root)
      @app_class = app_class
      @app_root  = app_root
    end

    attr_reader :app

    def call (params)
      action_path = params.delete("action")
      @app = build(params)
      @app.perform_action(action_path, params) unless action_path.nil?
      @app.to_s
    end

    def build (params)
      @app_class.new(params) do |config|
        config.app_root = @app_root
      end
    end
  end
end