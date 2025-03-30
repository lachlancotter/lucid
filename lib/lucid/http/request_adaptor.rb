require "uri"

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

      def state_reader (app_root: "/")
        case [has_message?, htmx?]
        when [true, true] then state_from_hx_current_url(app_root)
        when [true, false] then state_from_message_params
        else state_from_fullpath(app_root)
        end.tap do |result|
          Check[result].type(State::Reader, State::HashReader)
        end
      end

      def state_from_fullpath (app_root)
        fullpath     = @request.fullpath
        state_string = RequestAdaptor.normalize_path(fullpath, app_root)
        State::Reader.new(state_string)
      end

      def state_from_hx_current_url (app_root)
        current_url  = @request.get_header("HTTP_HX_CURRENT_URL")
        state_string = RequestAdaptor.normalize_path(current_url, app_root)
        State::Reader.new(state_string)
      end

      def state_from_message_params
        State::HashReader.new(raw_params["state"] || {})
      end

      def self.normalize_path (url, app_root)
        case url
        when "" then "/"
        when "/" then "/"
        when String
          uri     = URI.parse(url)
          pattern = app_root.sub(/\/$/, "")
          uri.path.sub(pattern, "").tap do |path|
            query = uri.query || ""
            path << "?" + query if query != ""
          end
        else
          raise ArgumentError, "Invalid URL: #{url.inspect}"
        end
      end

      def cookies
        @request.cookies
      end

      def htmx?
        @request.get_header("HTTP_HX_REQUEST") == "true"
      end

      def yield_link
        tap { yield message_params if has_link? }
      end

      def yield_command
        tap { yield message_params if has_command? }
      end

      def yield_no_message
        tap { yield unless has_message? }
      end

      def has_message?
        Message.present?(@request)
      end

      def has_link?
        has_message? && message_class.ancestors.include?(Lucid::Link)
      end

      def has_command?
        has_message? && message_class.ancestors.include?(Lucid::Command)
      end

      def message_params
        HTML::FormModel.new(
           message_class,
           raw_params.reject { |key, _| key == "state" }
        ) if has_message?
      end

      def message_name
        Message.decode_name(@request)
      end

      def message_class
        MessageName.to_class(message_name)
      end

      def raw_params
        Message.decode_params(@request) || {}
      end
    end
  end
end