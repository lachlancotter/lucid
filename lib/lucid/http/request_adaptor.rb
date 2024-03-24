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

      # def state (base_class, config)
      #   base_class.decode_state(href(config[:app_root]))
      # end

      def state_reader (config)
        if has_message?
          State::HashReader.new(message_params["state"])
        else
          State::Reader.new(href(config[:app_root]))
        end
      end

      def href (app_root)
        if @request.fullpath == app_root && app_root == "/"
          "/"
        else
          @request.fullpath.sub(/^#{app_root}/, "")
        end.tap do |result|
          Check[result].string.not_blank
        end
      end

      def has_message?
        Message.present?(@request)
      end

      def has_query?
        has_message? && message_class.ancestors.include?(Lucid::Link)
      end

      def has_command?
        has_message? && message_class.ancestors.include?(Lucid::Command)
      end

      def message
        if has_message?
          message_class.new(
             message_params.reject { |key, _| key == "state" }
          )
        else
          nil
        end
      end

      def message_name
        Message.decode_name(@request)
      end

      def message_class
        MessageName.to_class(message_name)
      end

      def message_params
        Message.decode_params(@request)
      end
    end
  end
end