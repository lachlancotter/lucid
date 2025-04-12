module Lucid
  module HTML
    #
    # A container for message parameters that can be used to generate
    # hypermedia controls and access validation errors.
    #
    class FormModel
      attr_reader :component_id, :form_name, :message_type, :message_params

      def initialize (component_id, form_name, message_type, message_params)
        @component_id   = Types.string[component_id]
        @form_name      = Types.symbol[form_name]
        @message_type   = Types.subclass(HTTP::Message)[message_type]
        @message_params = validate_params(message_params)
      end

      def or_default (default_params)
        if @message_params.empty?
          FormModel.new(@component_id, @form_name, @message_type, default_params)
        else
          self
        end
      end

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

      private

      def validate_params (params)
        case params
        when Hash then params
        when FormModel then params.to_h
        else raise ArgumentError, "Invalid message parameters: #{params.inspect}"
        end
      end
    end
  end
end