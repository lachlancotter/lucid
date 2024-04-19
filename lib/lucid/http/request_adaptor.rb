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

      def state_reader (app_root: "/")
        Match.on(has_message?, htmx?) do
          value(true, true) { state_from_hx_current_url(app_root) }
          value(true, false) { state_from_message_params }
          default { state_from_fullpath(app_root) }
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
        State::HashReader.new(message_params["state"] || {})
      end

      def self.normalize_path (url, app_root)
        Match.on(url) do
          value("") { "/" }
          value("/") { "/" }
          type(String) do
            uri   = URI.parse(url)
            uri.path.sub(app_root, "").tap do |path|
              query = uri.query || ""
              path << "?" + query if query != ""
            end
          end
        end
      end

      def htmx?
        @request.get_header("HTTP_HX_REQUEST") == "true"
      end

      def yield_link
        tap { yield message if has_link? }
      end

      def yield_command
        tap { yield message if has_command? }
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
        Message.decode_params(@request) || {}
      end
    end
  end
end