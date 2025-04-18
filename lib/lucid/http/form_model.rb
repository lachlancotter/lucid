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
        @message_params = validate_params(message_params)
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
        @message_params
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
        @message_type.schema.call(@message_params)
      end

      def form_action
        @message_type.url(@message_params)
      end

      def http_method
        @message_type.http_method
      end

      private

      def validate_params (params)
        deep_symbolize_keys(
           case params
           when Hash then params
           when MessageParams then params.to_h
           when FormModel then params.to_h
           else raise ArgumentError, "Invalid message parameters: #{params.inspect}"
           end
        )
      end

      def deep_symbolize_keys (obj)
        case obj
        when Hash
          obj.each_with_object({}) do |(k, v), result|
            result[k.to_sym] = deep_symbolize_keys(v)
          end
        when Array
          obj.map { |e| deep_symbolize_keys(e) }
        else
          obj
        end
      end
    end
  end
end