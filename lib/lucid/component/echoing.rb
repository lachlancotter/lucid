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
            binding      = Echo.new(props.env, name, message_class, except: except)
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
        def initialize (env, form_name, message_class, except: [])
          @env           = Types.hash[env]
          @form_name     = Types.symbol[form_name]
          @message_class = Types.subclass(Message)[message_class]
          @param_filter  = validate_filter(except)
        end

        def to_form_model
          HTML::FormModel.new(@form_name, @message_class, to_h)
        end

        def to_h
          active_form? ? filtered_params : {}
        end

        # Was this form submitted in the current request?
        def active_form?
          active_form_name == @form_name
        end

        private

        def validate_filter (filter)
          case filter
          when Symbol then [filter.to_s]
          when Array then filter.map { |f| f.to_s }
          else raise ArgumentError, "Invalid filter: #{filter.inspect}"
          end
        end

        def active_form_name
          raw_params["form_name"] ? Types.symbol[raw_params["form_name"]] : nil
        end

        def filtered_params
          raw_params.reject do |key, _|
            @param_filter.include?(key) || key == "form_name"
          end
        end

        def raw_params
          @raw_params ||= request.POST.merge(request.GET)
        end

        def request
          @request ||= Rack::Request.new(@env)
        end
      end

    end
  end
end