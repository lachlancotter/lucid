module Lucid
  module HTML
    #
    # Build an HTML form to compose a Message.
    #
    class Form
      def initialize (message_params, **opts, &block)
        @message_params = message_params
        @options        = opts
        @block          = block
      end

      def to_s
        template.render
      end

      def template
        Papercraft.html do |message_params|
          form action: message_params.form_action, method: message_params.http_method do
            emit_yield Builder.new(self, message_params, Path.new)
          end
        end.apply(@message_params, &@block)
      end

      class Builder
        include Templating

        def initialize (renderer, message_params, path = Path.new)
          @renderer       = renderer
          @message_params = Types.Instance(FormModel)[message_params]
          @path           = Types.Instance(Path)[path]
        end

        def emit (template)
          @renderer.emit(template)
        end

        def scoped (name)
          yield Builder.new(
             @renderer,
             @message_params,
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
          @path.concat(key).inject(@message_params.to_h) do |params, entry|
            params.fetch(entry) { raise KeyError, "Key not found: #{entry}" }
          end
        end

        def errors (key)
          @path.concat(key).inject(@message_params.errors) do |errors, entry|
            raise KeyError, errors.to_s if errors.is_a?(Array)
            errors.fetch(entry) { raise KeyError, "Key not found: #{entry}" }
          end
        end
        
        def has_helper? (name)
          respond_to?(name)
        end

        class << self
          def template (name, &block)
            if block_given?
              define_method(name) do |*args|
                template(name).render(*args)
              end
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

        template :hidden do |key, options = {}|
          input({
             type:  :hidden,
             name:  field_name(key),
             value: field_value(key),
             id:    field_id(key)
          }.merge(options))
        end

        template :label do |key, text = key, options = {}|
          label(key, { for: field_id(key) }.merge(options)) {
            emit text
          }
        end

        template :text do |key, options = {}|
          input({
             type:  :text,
             name:  field_name(key),
             value: field_value(key),
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