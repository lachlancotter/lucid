module Lucid
  module HTTP
    #
    # Data model for generating HTML form elements representing messages, with 
    # validation messages. Also used to extract a message from an HTTP request.
    #
    class FormModel
      attr_reader :component_id, :form_name, :message_type, :message_params

      def initialize (message_type, message_params, component_id: "", form_name: :nil_form)
        @component_id   = Types.string[component_id]
        @form_name      = Types.symbol[form_name]
        @message_type   = Types.subclass(Message)[message_type]
        @message_params = parse_params(message_params)
      end

      #
      # Convenience method for constructing a FormModel with default parameters
      # if the receiving instance is empty. 
      # 
      def or_default (default_params)
        if @message_params.empty?
          FormModel.new(@message_type, default_params,
             component_id: @component_id, form_name: @form_name
          )
        else
          self
        end
      end

      # ===================================================== #
      #    Requests
      # ===================================================== #

      def yield_link
        tap { yield to_message if is_link? && valid? }
      end

      def yield_command
        tap { yield to_message if is_command? && valid? }
      end

      def yield_invalid
        tap { yield to_h, errors unless valid? }
      end

      def to_message
        @message_type.new(result.to_h)
      end

      def is_link?
        @message_type.ancestors.include?(Link)
      end

      def is_command?
        @message_type.ancestors.include?(Command)
      end

      def to_h
        @message_params.to_h
      end

      # ===================================================== #
      #    Validation
      # ===================================================== #

      def valid?
        result.success?
      end

      def errors
        result.errors
      end

      def result
        @message_type.schema.call(@message_params.to_h)
      end

      def form_action
        @message_type.url(@message_params)
      end

      def http_method
        @message_type.http_method
      end

      private

      def parse_params (params)
        Types.instance(MessageParams)[
           case params
           when MessageParams then params
           when Hash then MessageParams.new(params)
           when FormModel then params.message_params
           else raise ArgumentError, "Invalid message parameters: #{params.inspect}"
           end
        ]
      end
    end
  end
end