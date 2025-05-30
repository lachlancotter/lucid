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

      def echos
        @echos ||= {}
      end

      def reset (form_name)
        if echos.key?(form_name)
          echos[form_name].reset
          forms[form_name] = echos[form_name].to_form_model
          fields[form_name].notify
        end
      end

      private

      module ClassMethods
        #
        # Create a FormModel that echos back the parameters from the request.
        # The block can be used to modify the FormModel before it is used to
        # generate the HTML.
        # 
        def echo (name, message_class, except: [], &block)
          after_initialize do
            request      = props.container[:request]
            echos[name]  = Echo.new(request, self, name, message_class, filter: except, &block)
            forms[name]  = echos[name].to_form_model
            fields[name] = Field.new(self) { forms[name] }
          end
          define_method(name) { forms[name] }
          after_build { fields[name].notify if echos[name].active_form? }
        end
      end

      #
      # Access and filter form parameters from the request so that they can
      # be 'echoed' back to the view.
      # 
      class Echo
        def initialize (request, component, form_name, message_class, filter: [], &block)
          @request       = Types.instance(HTTP::RequestAdaptor)[request]
          @component     = Types.component[component]
          @form_name     = Types.symbol[form_name]
          @message_class = Types.subclass(Message)[message_class]
          @param_filter  = filter
          @config_block  = block
          @reset         = false
        end

        def to_form_model
          model_options = { component_id: @component.path.to_s, form_name: @form_name }
          model         = HTTP::FormModel.new(@message_class, to_h, **model_options)
          model         = @component.instance_exec(model, &@config_block) if @config_block
          model
        end

        def to_h
          return {} if @reset
          active_form? ? message_params.to_h : {}
        end

        def reset
          @reset = true
        end

        # Was this form submitted in the current request?
        def active_form?
          active_component_path == @component.path.to_s &&
             active_form_name == @form_name
        end

        private

        def active_form_name
          message_params.active_form_name
        end

        def active_component_path
          message_params.active_component_path
        end

        def message_params
          @request.message_params(filter: @param_filter)
        end
      end

    end
  end
end