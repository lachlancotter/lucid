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
            binding      = Echo.new(props.env, self, name, message_class, except: except)
            form_model   = binding.to_form_model
            form_model   = block.call(form_model) if block_given?
            echos[name]  = binding
            forms[name]  = form_model
            fields[name] = Field.new(self) { forms[name] }
          end

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
        def initialize (env, component, form_name, message_class, except: [])
          @env           = Types.hash[env]
          @component     = Types.component[component]
          @form_name     = Types.symbol[form_name]
          @message_class = Types.subclass(Message)[message_class]
          @param_filter  = validate_filter(except)
        end

        def to_form_model
          HTML::FormModel.new(@message_class, to_h,
             component_id: @component.path.to_s, form_name: @form_name
          )
        end

        def to_h
          active_form? ? filtered_params : {}
        end

        # Was this form submitted in the current request?
        def active_form?
          active_component_path == @component.path.to_s &&
             active_form_name == @form_name
        end

        private

        def validate_filter (filter)
          case filter
          when String then [filter]
          when Symbol then [filter.to_s]
          when Array then filter.map { |f| f.to_s }
          else raise ArgumentError, "Invalid filter: #{filter.inspect}"
          end
        end

        def active_form_name
          form_param = message_params[HTML::Form::FORM_NAME_PARAM_KEY]
          form_param ? Types.symbol[form_param] : nil
        end

        def active_component_path
          component_param = message_params[HTML::Form::COMPONENT_PATH_PARAM_KEY]
          component_param ? Types.string[component_param] : nil
        end

        def filtered_params
          message_params.reject do |key, _|
            @param_filter.include?(key) || %w[form component].include?(key)
          end
        end

        def message_params
          request.message_params
          # @raw_params ||= request.POST.merge(request.GET)
        end

        def request
          # TODO we should pass the container instead of the env
          @request ||= HTTP::RequestAdaptor.new(Rack::Request.new(@env))
        end
      end

    end
  end
end