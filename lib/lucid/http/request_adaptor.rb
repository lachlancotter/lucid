require "uri"

module Lucid
  module HTTP
    #
    # Wrapper around an HTTP request that provides an API
    # for parsing the request and extracting component params
    # and messages.
    #
    class RequestAdaptor
      extend Forwardable

      def initialize (request, url_base: "/")
        @request  = request
        @url_base = url_base
      end

      def_delegators :@request,
         :env, :request_method, :fullpath, :get_header, :post?, :GET, :POST

      def state_reader
        Types.reader[
           case [has_message?, htmx?]
           when [true, true] then state_from_hx_current_url
           when [true, false] then state_from_message_params
           else state_from_fullpath
           end
        ]
      end

      def state_from_fullpath
        state_string = Endpoint.relative(fullpath, base: @url_base)
        State::Reader.new(state_string)
      end

      def state_from_hx_current_url
        current_url  = get_header("HTTP_HX_CURRENT_URL")
        state_string = Endpoint.relative(current_url, base: @url_base)
        State::Reader.new(state_string)
      end

      def state_from_message_params
        State::HashReader.new(state_params)
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
        MessageName.valid?(message_path)
      end

      def message_class
        MessageName.to_class(message_path)
      end
      
      def message_path
        Endpoint.relative(fullpath, base: @url_base)
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