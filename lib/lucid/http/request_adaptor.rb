require "lucid/http/message_name"

module Lucid
  module HTTP
    #
    # Wrapper around an HTTP request that provides an API
    # for parsing the request and extracting component params
    # and messages.
    #
    class RequestAdaptor
      def initialize (request)
        @request = request
      end

      def state (base_class, config)
        base_class.decode_href(@request.fullpath, config)
      end

      def has_message?
        @request.params["msg"] != nil &&
           @request.params["msg"] != ""
      end

      def has_query?
        has_message? && message_class.ancestors.include?(Lucid::Link)
      end

      def has_command?
        has_message? && message_class.ancestors.include?(Lucid::Command)
      end

      def message
        if has_message?
          message_class.new(message_params)
        else
          nil
        end
      end

      def message_name
        @request.params["msg"]
      end

      def message_class
        MessageName.to_class(message_name)
      end

      def message_params
        @request.params[message_name]
      end
    end
  end
end