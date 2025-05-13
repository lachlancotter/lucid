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
            binding      = Echo.new(request, self, name, message_class, except: except)
            form_model   = binding.to_form_model
            form_model   = instance_exec(form_model, &block) if block_given?
            echos[name]  = binding
            forms[name]  = form_model
            fields[name] = Field.new(self) { forms[name] }
          end

          define_method(name) { forms[name] }

          after_build do
            fields[name].notify if echos[name].active_form?
          end
        end
      end

      #
      # Access and filter form parameters from the request so that they can
      # be 'echoed' back to the view.
      # 
      class Echo
        def initialize (request, component, form_name, message_class, except: [])
          @request       = Types.instance(HTTP::RequestAdaptor)[request]
          @component     = Types.component[component]
          @form_name     = Types.symbol[form_name]
          @message_class = Types.subclass(Message)[message_class]
          @param_filter  = except
        end

        def to_form_model
          HTTP::FormModel.new(@message_class, to_h,
             component_id: @component.path.to_s, form_name: @form_name
          )
        end

        def to_h
          active_form? ? message_params.to_h : {}
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