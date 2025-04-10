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
        message = @message
        Form.new(form_params) do |f|
          emit f.submit(button_label)
          message.to_h.each do |key, value|
            emit f.hidden(key, value: value)
          end
        end.template
      end

      private

      def form_params
        FormModel.new(:button, @message.class, @message.to_h)
      end
    end
  end
end