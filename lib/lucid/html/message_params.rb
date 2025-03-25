module Lucid
  module HTML
    #
    # A container for message parameters that can be used to generate
    # hypermedia controls and access validation errors.
    #
    class MessageParams
      def initialize (message_type, message_params)
        @message_type   = Types.Instance(Class)[message_type]
        @message_params =
           case message_params
           when Hash
             message_params
           when MessageParams
             message_params.to_h
           else
             raise ArgumentError,
                "Invalid message parameters: #{message_params.inspect}"
           end
      end

      attr_reader :message_type, :message_params

      def valid?
        result.success?
      end

      def errors
        result.errors
      end

      def result
        @message_type.schema.call(@message_params)
      end

      def to_message
        @message_type.new(result.to_h)
      end

      def to_h
        @message_params
      end

      #
      # Generate an HTML form control with these parameters.
      #
      def form (**opts, &block)
        Form.new(self, **opts, &block).template
      end

      def form_action
        @message_type.url(@message_params)
      end

      def http_method
        @message_type.http_method
      end
    end
  end
end