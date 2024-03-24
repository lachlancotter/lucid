require "checked"
require "lucid/struct"
require "lucid/http/message_name"
require "lucid/html/anchor"

module Lucid
  #
  # Messages are value objects that represent the intent of a user
  # to interact with the application. They can be encoded as HTTP
  # requests and decoded from HTTP responses.
  #
  class Message < Struct
    POST          = "POST".freeze
    GET           = "GET".freeze
    MESSAGE_PARAM = "msg".freeze
    NAME_PARAM    = "name".freeze
    ARGS_PARAM    = "args".freeze
    # TARGET_PARAM  = "target".freeze
    MODE_PARAM    = "mode".freeze
    EXECUTE       = "execute".freeze
    VALIDATE      = "validate".freeze

    class << self
      def present? (request)
        request.params[MESSAGE_PARAM] != nil &&
           request.params[MESSAGE_PARAM][NAME_PARAM] != nil
      end

      def decode_name (request)
        request.params[MESSAGE_PARAM][NAME_PARAM]
      end

      def decode_params (request)
        get_params  = request.GET.dig(MESSAGE_PARAM, ARGS_PARAM) || {}
        post_params = request.POST.dig(MESSAGE_PARAM, ARGS_PARAM) || {}
        get_params.merge(post_params)
      end
    end

    def query_params
      {
         MESSAGE_PARAM => {
            NAME_PARAM => message_name.to_s,
            ARGS_PARAM => params.map { |k, v| [k.to_s, v] }.to_h
         }
      }
    end

    def name_param
      "msg[name]"
    end

    def form_field_path
      Path.new([MESSAGE_PARAM, ARGS_PARAM])
    end

    #
    # Messages types have a name that is used to identify them in
    # HTTP requests and responses.
    #
    def message_name
      HTTP::MessageName.encode(self.class)
    end

    #
    # Convert the message into a URL that can be used to invoke it.
    #
    def href
      Message.context.href(self)
    end

    #
    # Encode the state of the current context.
    #
    def encode_state
      Message.context.encode_state
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
        old_context = @context
        @context    = Context.new(app)
        yield
      ensure
        @context = old_context
      end

      attr_reader :context
    end

    #
    # API for message evaluation context.
    #
    class Context


      def initialize (app)
        @app = Check[app].type(Component::Base, App::Cycle).value
      end

      def href (message)
        @app.href(message)
      end

      def encode_state
        @app.state.to_h.to_json
      end
    end
  end
end