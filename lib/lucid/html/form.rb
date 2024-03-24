require "lucid/renderable"

module Lucid
  module HTML
    #
    # Build an HTML form to compose a Message.
    #
    class Form
      def initialize (message, &block)
        @message = message
        @block   = block
      end

      def to_s
        template.render
      end

      def template
        Papercraft.html do |message|
          form action: message.href, method: message.http_method do
            emit_yield Builder.new(self, message.params, message.errors, Path.new)
          end
        end.apply(@message, &@block)
      end

      class Builder

        include Renderable

        def initialize (renderer, data, errors, path = Path.new)
          @renderer = renderer
          @data     = Check[data].hash.value
          @errors   = Check[errors].hash.value
          @path     = path
        end

        attr_reader :data, :errors

        def emit (template)
          @renderer.emit(template)
        end

        def struct (name)
          yield Builder.new(
             @renderer,
             nested_data(name),
             nested_errors(name),
             @path.concat(name)
          )
        end

        def nested_data (key)
          @data.fetch(key, {}).tap do |data|
            Check[data].hash
          end
        end

        def nested_errors (key)
          @errors.fetch(key, {}).tap do |errors|
            Check[errors].hash
          end
        end

        def field_id (key)
          Check[key].type(String, Symbol)
          @path.concat(key).join("_")
        end

        def field_name (key)
          Check[key].type(String, Symbol)
          if @path.depth == 0
            key.to_s
          else
            @path.head + "[#{ @path.tail.concat(key).components.join('][') }]"
          end
        end

        def field_value (key)
          Check[key].type(String, Symbol)
          @data.fetch(key.to_s, "")
        end

        class << self
          def template (name, &block)
            super(name, &block)
            define_method(name) do |*args|
              template(name).render(*args)
            end
            define_method("#{name}!") do |*args|
              emit template(name).render(*args)
            end
          end
        end

        template :hidden do |key, options = {}|
          input({
             type:  :hidden,
             name:  field_name(key),
             value: field_value(key),
             id:    field_id(key)
          }.merge(options))
        end

        template :label do |key, text, options = {}|
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