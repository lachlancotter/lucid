module Lucid
  module HTTP
    #
    # Messages are value objects that represent the intent of a user
    # to interact with the application. They can be encoded as HTTP
    # requests and decoded from HTTP responses.
    #
    class Message < Lucid::Message
      POST = "POST".freeze
      GET  = "GET".freeze

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

      class << self
        def url (params)
          URL.new(self, params).to_s
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
          def initialize (message_type, message_params)
            @message_type   = Types.subclass(Message)[message_type]
            @message_params = parse_params(message_params)
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
            @query_params ||= @message_type.merge_app_state(@message_params.to_h)
          end

          private

          def parse_params (params)
            case params
            when Hash then params
            when MessageParams then params.to_h
            else raise ArgumentError, "Invalid params: #{params.inspect}"
            end
          end

          def encode_params (params)
            Rack::Utils.build_nested_query(params)
          end
        end

        #
        # Messages types have a name that is used to identify them in
        # HTTP requests and responses.
        #
        def message_name
          MessageName.from_class(self)
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