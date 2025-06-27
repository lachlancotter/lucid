module Lucid
  module HTML
    #
    # Build an HTML form to compose a Message.
    #
    class Form
      def initialize (form_model, **opts, &block)
        @form_model = Types.instance(HTTP::FormModel)[form_model]
        @options    = Types.hash[opts]
        @block      = block
      end

      def to_s
        template.render
      end

      def template
        Papercraft.html do |form_model|
          Builder.new(self, form_model).tap do |builder|
            form action: form_model.form_action, method: form_model.http_method do
              builder.hidden(HTTP::MessageParams::COMPONENT_PATH_PARAM_KEY, value: form_model.component_id)
              builder.hidden(HTTP::MessageParams::FORM_NAME_PARAM_KEY, value: form_model.form_name)
              builder.hidden(HTTP::MessageParams::CSRF_TOKEN_PARAM_KEY, value: form_model.csrf_token) if form_model.csrf_token
              emit_yield builder
            end
          end
        end.apply(@form_model, &@block)
      end

      class Builder
        def initialize (renderer, form_model, path = Path.new)
          @renderer   = renderer
          @form_model = Types.instance(HTTP::FormModel)[form_model]
          @path       = Types.instance(Path)[path]
        end

        def emit (template)
          @renderer.emit(template)
        end

        def scoped (name)
          yield Builder.new(@renderer, @form_model, @path.concat(name))
        end

        def field_id (key)
          Types.union(String, Symbol)[key]
          @path.concat(key).join("_")
        end

        def field_name (key)
          Types.union(String, Symbol)[key]
          if @path.depth == 0
            key.to_s
          else
            @path.head.to_s + "[#{ @path.tail.concat(key).components.join('][') }]"
          end
        end

        def field_value (key)
          Types.union(String, Symbol)[key]
          @path.concat(key).inject(@form_model.to_h) do |params, entry|
            params.fetch(entry.to_sym) { raise KeyError, "Key not found: #{entry}" }
          end
        end

        def errors (key)
          @path.concat(key).inject(@form_model.errors) do |errors, entry|
            # raise KeyError, errors.to_s if errors.is_a?(Array)
            errors.fetch(entry.to_sym) { raise KeyError, "Key not found: #{entry}" }
          end
        end

        def has_helper? (name)
          respond_to?(name)
        end

        def hidden (key, value: nil, **attrs)
          input_attrs = {
             type:  :hidden,
             name:  field_name(key),
             value: value || field_value(key),
             id:    field_id(key)
          }.merge(attrs)
          @renderer.tag(:input, input_attrs)
        end

        def label (key, text = key, **attrs)
          label_attrs = { for: field_id(key) }.merge(attrs)
          label_text  = text
          @renderer.tag(:label, label_attrs) { text label_text }
        end

        def text (key, value: nil, **attrs)
          input_attrs = {
             type:  :text,
             name:  field_name(key),
             value: value || field_value(key),
             id:    field_id(key)
          }.merge(attrs)
          @renderer.tag(:input, input_attrs)
        end

        def password (key, value: nil, **attrs)
          input_attrs = {
             type:  :password,
             name:  field_name(key),
             value: value || field_value(key),
             id:    field_id(key)
          }.merge(attrs)
          @renderer.tag(:input, input_attrs)
        end

        def textarea (key, value: nil, **attrs)
          textarea_attrs = { name: field_name(key), id: field_id(key) }.merge(attrs)
          textarea_value = value || field_value(key)
          @renderer.tag(:textarea, textarea_attrs) { text textarea_value }
        end

        def select (name, value: field_value(name), **attrs, &block)
          tag_attrs      = { name: field_name(name), id: field_id(name) }.merge(attrs)
          option_builder = OptionBuilder.new(@renderer, name, value)
          @renderer.tag(:select, tag_attrs) { block.call(option_builder) if block_given? }
        end

        class OptionBuilder
          def initialize (renderer, name, value)
            @renderer = renderer
            @name     = (Types.string | Types.symbol)[name]
            @value    = value
          end

          def option (value, label = value, **attrs)
            option_attrs = { value: value, selected: (@value == value) }.merge(attrs)
            @renderer.tag(:option, option_attrs) { text label }
          end
        end

        def submit (label, **attrs)
          input_attrs = { type: :submit, value: label }.merge(attrs)
          @renderer.tag(:input, input_attrs)
        end

        def radio_button (key, value, checked: false, **attrs)
          input_attrs = {
             type:    :radio,
             name:    field_name(key),
             value:   value,
             id:      field_id(key),
             checked: checked || (field_value(key) == value)
          }.merge(attrs)
          @renderer.tag(:input, input_attrs)
        end

      end
    end
  end
end