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
              emit builder.hidden(HTTP::MessageParams::COMPONENT_PATH_PARAM_KEY, value: form_model.component_id)
              emit builder.hidden(HTTP::MessageParams::FORM_NAME_PARAM_KEY, value: form_model.form_name)
              emit_yield builder
            end
          end
        end.apply(@form_model, &@block)
      end

      class Builder
        include Templating

        def initialize (renderer, form_model, path = Path.new)
          @renderer   = renderer
          @form_model = Types.instance(HTTP::FormModel)[form_model]
          @path       = Types.instance(Path)[path]
        end

        def emit (template)
          @renderer.emit(template)
        end

        def scoped (name)
          yield Builder.new(
             @renderer,
             @form_model,
             @path.concat(name)
          )
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

        class << self
          def template (name, &block)
            if block_given?
              define_method(name) do |*args, **opts|
                template(name).render(*args, **opts)
              end
              # Maybe we should remove the bang version.
              define_method("#{name}!") do |*args|
                emit template(name).render(*args)
              end
            end
            super(name, &block)
          end
        end

        def template (name)
          self.class.template(name).bind(self)
        end

        template :hidden do |key, value: nil, **options|
          input({
             type:  :hidden,
             name:  field_name(key),
             value: value || field_value(key),
             id:    field_id(key)
          }.merge(options))
        end

        template :label do |key, text = key, options = {}|
          label(key, { for: field_id(key) }.merge(options)) {
            emit text
          }
        end

        template :text do |key, value: nil, **options|
          input({
             type:  :text,
             name:  field_name(key),
             value: value || field_value(key),
             id:    field_id(key)
          }.merge(options))
        end

        template :textarea do |key, value: nil, **options|
          tag(:textarea, {
             name:  field_name(key),
             value: value || field_value(key),
             id:    field_id(key)
          }.merge(options))
        end

        template :submit do |label|
          input(type: :submit, value: label)
        end

      end
    end
  end
end