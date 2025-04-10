module Lucid
  module Component
    #
    # Capture invalid messages so they can be echoed back to the client.
    #
    module Echoing
      def self.included (base)
        base.extend ClassMethods
      end

      def forms
        @forms ||= {}
      end

      private

      def params_for_form (form_name)
        request     = Rack::Request.new(props.env)
        form_params = request.POST.merge(request.GET)
        if form_params["form_name"] == form_name.to_s
          form_params.tap { |h| h.delete("form_name") }
        else
          {}
        end
      end

      module ClassMethods
        def echo (name, message_class)
          Types.symbol[name]
          Types.subclass(Message)[message_class]
          after_initialize do
            forms[name]  = HTML::FormModel.new(message_class, params_for_form(name))
            fields[name] = Field.new(self) { forms[name] }
          end
        end
      end
    end
  end
end