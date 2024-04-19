module Lucid
  #
  # Messages are value objects that represent the intent of a user
  # to interact with the application. They can be encoded as HTTP
  # requests and decoded from HTTP responses.
  #
  class Message < Struct
    POST = "POST".freeze
    GET  = "GET".freeze
    # TARGET_PARAM  = "target".freeze
    MODE_PARAM = "mode".freeze
    EXECUTE    = "execute".freeze
    VALIDATE   = "validate".freeze

    class << self
      #
      # Checks whether the request contains a message.
      #
      def present? (request)
        request.fullpath.match?(/\/@\/\w+/)
      end

      def decode_name (request)
        pattern = /\/@\/(.*?)\?/
        path    = request.fullpath.match(pattern)[1]
        HTTP::MessageName.decode(path)
      end

      def decode_params (request)
        (request.GET || {}).merge(request.POST || {})
      end
    end

    #
    # Convert the message into a URL that can be used to invoke it.
    #
    def href
      "/@/#{message_name}?#{encode_params}"
    end

    #
    # Messages types have a name that is used to identify them in
    # HTTP requests and responses.
    #
    def message_name
      HTTP::MessageName.encode(self.class)
    end

    def query_params
      if Message.context.respond_to?(:merge_state)
        Message.context.merge_state(params.to_h)
      else
        params.to_h
      end
    end

    #
    # Encode the state of the current context.
    #
    def encode_params
      Rack::Utils.build_nested_query(query_params)
    end

    #
    # Generate a link to send this message.
    #
    def link (text)
      HTML::Anchor.new(href, text: text)
    end

    #
    # Generate a button to send this message.
    #
    def button (label)
      HTML::Button.new(self, label).template
    end

    #
    # Generate a form to compose this message.
    #
    def form (&block)
      HTML::Form.new(self, &block).template
    end

    class << self
      #
      # Generate a link to get this message type.
      #
      def link (text, params = {})
        new(params).link(text)
      end

      #
      # Generate a button to send this message type.
      #
      def button (label, params = {})
        new(params).button(label)
      end

      #
      # Generate a form to compose this message type.
      #
      def form (params = {}, &block)
        raise "no block" unless block
        new(params).form(&block)
      end

      #
      # Creates an evaluation context for messages so they can be
      # converted into URLs including the current application state.
      #
      def with_context (app)
        Check[app].type(Component::Base, App::Cycle).value
        old_context = @context
        @context    = app
        yield
      ensure
        @context = old_context
      end

      attr_reader :context
    end

    #
    # API for message evaluation context.
    #
    # class Context
    #   def initialize (app)
    #     @app = Check[app].type(Component::Base, App::Cycle).value
    #   end
    #
    #   def href
    #     @app.href
    #   end
    #
    #   def encode_state
    #     @app.state.to_h.to_json
    #   end
    # end
  end
end