module Lucid
  module HTTP
    #
    # Encodes a message as a URL.
    #
    class URL
      def initialize (message_type, message_params, base: "")
        @message_type   = Types.subclass(Message)[message_type]
        @message_params = parse_params(message_params)
        @base           = base
      end

      def to_s
        path + query_string
      end

      def path
        "#{@base}/@/#{@message_type.message_name}"
      end

      def query_string
        return "" if @message_params.empty?
        "?" + encode_params(@message_params)
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
  end
end