require "lucid/message"
require "lucid/html/button"
require "lucid/html/form"

module Lucid
  class Command < Message
    #
    #
    #
    class << self
      def validate (&block) end

      def button (label, params = {})
        new(params).button(label)
      end

      def form (params = {}, &block)
        raise "no block" unless block
        new(params).form(&block)
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
      HTML::Button.new(self, label).template
    end

    def form (&block)
      HTML::Form.new(self, &block).template
    end

    #
    #
    #
    class Context
      def initialize (app)
        @app = app
      end

      def href (command)
        @app.href(command)
        # Location.new(@app.state, @app.routes).to_s
      end

      def encode_state (command)
        @app.state.to_h.to_json
      end
    end

  end
end