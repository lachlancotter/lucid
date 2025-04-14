module Lucid
  module HTTP
    #
    # Messages are value objects that represent the intent of a user
    # to interact with the application. They can be encoded as HTTP
    # requests and decoded from HTTP responses.
    #
    class Message < Lucid::Message
      POST       = "POST".freeze
      GET        = "GET".freeze
      PATTERN    = /^(?:.*?\/@\/)(.+?)(\?.*)?$/

      #
      # Indicates that the given request path does not match
      # the expected format.
      #
      class InvalidName < StandardError
        def self.check (fullpath)
          raise new(fullpath) unless fullpath.match?(PATTERN)
        end

        def initialize (fullpath)
          super("Cannot parse message URL: #{fullpath}")
        end
      end

      #
      # Convert the message into a URL that can be used to invoke it.
      #
      def url
        self.class.url(to_h)
      end

      #
      # Build the query parameters for this message.
      #
      def query_params
        self.class.merge_app_state(to_h)
      end

      #
      # Generate a link to send this message.
      #
      # def link (text, **opts, &block)
      #   HTML::Anchor.new(self, text: text, **opts, &block).template
      # end
      #
      # #
      # # Generate a button to send this message.
      # #
      # def button (label, **opts)
      #   HTML::Button.new(self, label, **opts).template
      # end

      class << self
        def url (params)
          URL.new(self, Types.hash[params]).to_s
        end

        def http_method
          GET # Default to GET
        end

        def get?
          http_method == GET
        end

        def post?
          http_method == POST
        end

        #
        # Encodes a message as a URL.
        #
        class URL
          def initialize (message_type, params)
            @message_type = Types.subclass(Message)[message_type]
            @params       = Types.hash[params]
          end

          def to_s
            path + query_string
          end

          def path
            "/@/#{@message_type.message_name}"
          end

          def query_string
            if query_params.empty?
              ""
            else
              "?" + encode_params(query_params)
            end
          end

          def query_params
            @query_params ||= @message_type.merge_app_state(@params)
          end

          private

          def encode_params (params)
            Rack::Utils.build_nested_query(params)
          end
        end

        #
        # Checks whether the request contains a message.
        #
        def present? (request)
          request.fullpath.match?(PATTERN)
        end

        #
        # Messages types have a name that is used to identify them in
        # HTTP requests and responses.
        #
        def message_name
          MessageName.encode(self)
        end

        def decode_name (request)
          InvalidName.check(request.fullpath)
          path = request.fullpath.match(PATTERN)[1]
          MessageName.decode(path)
        end

        def decode_params (request)
          (request.GET || {}).merge(request.POST || {})
        end

        #
        # Stores the current application context for the duration of the block.
        # This enables messages to be encoded with the current application state.
        #
        def with_app_state (cycle, &block)
          old_context  = @app_context
          @app_context = cycle
          block.call
        ensure
          @app_context = old_context
        end

        attr_reader :app_context

        def merge_app_state (params)
          if Message.app_context.nil?
            params
          else
            Message.app_context.merge_state(
               get? ? params : {}
            )
          end
        end
      end
    end
  end
end