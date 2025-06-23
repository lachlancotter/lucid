module Lucid
  module HTML
    class Button
      def initialize (message, label, **opts)
        @message = message
        @label   = label
        @options = opts
      end

      def to_s
        template.render
      end

      def template
        button_label = @label
        message      = @message
        options      = @options
        Form.new(form_model) do |f|
          f.submit(button_label, **options)
          message.to_h.each do |key, value|
            f.hidden(key, value: value)
          end
        end.template
      end

      private

      def form_model
        HTTP::FormModel.new(@message.class, @message.to_h,
           component_id: "", form_name: :button, csrf_token: @options[:csrf_token],
        )
      end
    end
  end
end