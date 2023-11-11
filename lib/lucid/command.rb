module Lucid
  class Command < OpenStruct
    #
    #
    #
    class << self
      def validate (&block) end

      def button (label, params = {})
        new(params).button(label)
      end

      def with_context (app)
        old_context = @context
        @context    = Context.new(app)
        yield
      ensure
        @context = old_context
      end

      attr_reader :context
    end

    attr_reader :params

    def href
      Command.context.href(self)
    end

    def http_method
      :post
    end

    def encode_state
      Command.context.encode_state(self)
    end

    def button (label)
      Button.new(self, label).to_s
    end

    #
    #
    #
    class Context
      def initialize (app)
        @app = app
      end

      def href (command)
        Location.new(@app.state, @app.routes).to_s
      end

      def encode_state (command)
        @app.state.to_h.to_json
      end
    end

  end
end