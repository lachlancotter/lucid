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
      # Encode this message as a URL.
      #
      def url
        self.class.url(query_params)
      end

      def query_params
        to_h
      end

      # def query_params (state = Message.current_state)
      #   MessageParams.new(to_h).merge_state(state).to_h
      # end

      # ===================================================== #
      #    Class Methods
      # ===================================================== #

      class << self
        def url (message_params)
          URL.new(self, build_query(message_params), base: Message.url_base).to_s
        end

        def build_query (message_params)
          parse_message_params(post? ? {} : message_params)
             .merge_state(Message.current_state).to_h
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
        # Messages types have a name that is used to identify them in
        # HTTP requests and responses.
        #
        def message_name
          MessageName.from_class(self)
        end

        # 
        # Stores the current app state in a global variable for the duration
        # of the block. This is a convenient way to pass state when generating
        # URLs from messages.
        #
        def with_state (state, &block)
          old_state      = @current_state
          @current_state = state
          block.call
        ensure
          @current_state = old_state
        end

        def current_state
          @current_state || {}
        end

        def with_url_base (base, &block)
          old_url_base = @url_base
          @url_base    = base
          block.call
        ensure
          @url_base = old_url_base
        end

        def url_base
          @url_base || ""
        end

        private

        def parse_message_params (message_params)
          case message_params
          when Hash then MessageParams.new(message_params)
          when MessageParams then message_params
          else raise ArgumentError, "Invalid params: #{message_params.inspect}"
          end
        end
      end
    end
  end
end