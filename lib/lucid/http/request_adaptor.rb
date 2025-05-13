require "uri"

module Lucid
  module HTTP
    #
    # Wrapper around an HTTP request that provides an API
    # for parsing the request and extracting component params
    # and messages.
    #
    class RequestAdaptor < SimpleDelegator
      def state_reader (app_root: "/")
        Types.reader[
           case [has_message?, htmx?]
           when [true, true] then state_from_hx_current_url(app_root)
           when [true, false] then state_from_message_params
           else state_from_fullpath(app_root)
           end
        ]
      end

      def state_from_fullpath (app_root)
        state_string = RequestAdaptor.normalize_path(fullpath, app_root)
        State::Reader.new(state_string)
      end

      def state_from_hx_current_url (app_root)
        current_url  = get_header("HTTP_HX_CURRENT_URL")
        state_string = RequestAdaptor.normalize_path(current_url, app_root)
        State::Reader.new(state_string)
      end

      def state_from_message_params
        State::HashReader.new(state_params)
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

      def htmx?
        get_header("HTTP_HX_REQUEST") == "true"
      end

      def yield_link (&block)
        form_model.yield_link(&block)
      end

      def yield_command (&block)
        form_model.yield_command(&block)
      end
      
      def yield_invalid (&block)
        form_model.yield_invalid(&block)
      end

      def form_model
        FormModel.new(message_class, message_params) if has_message?
      end

      def has_message?
        MessageName.valid?(fullpath)
      end

      def message_class
        MessageName.to_class(fullpath)
      end

      def state_params
        message_params.state
      end

      def message_params (filter: [])
        MessageParams.new(raw_params, filter: filter)
      end

      def raw_params
        @raw_params ||= if post?
          (self.POST || {}).merge(self.GET || {})
        else
          (self.GET || {})
        end
      end
    end
  end
end