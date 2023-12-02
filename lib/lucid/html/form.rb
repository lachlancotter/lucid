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
            # input type: :hidden, name: :state, value: message.encode_state
            input type: :hidden, name: Message::NAME_PARAM, value: message.message_name
            emit_yield Builder.new(self, message.params, message.errors, Path.new(Message::ARGS_PARAM))
          end
        end.apply(@message, &@block)
      end

      class Builder
        include Renderable

        def initialize (renderer, data, errors, path = Path.new)
          raise "no data" unless data
          @renderer = renderer
          @data     = data
          @errors   = errors
          @path     = path
        end

        attr_reader :data, :errors

        def emit (template)
          @renderer.emit(template)
        end

        def struct (name)
          yield Builder.new(
             @renderer,
             @data.fetch(name, {}),
             @errors.fetch(name, {}),
             @path.concat(name)
          )
        end

        def field_id (key)
          raise "invalid key: #{key}" unless
             key.is_a?(String) || key.is_a?(Symbol)
          @path.concat(key).join("_")
        end

        def field_name (key)
          if @path.depth == 0
            key.to_s
          else
            @path.head + "[#{ @path.tail.concat(key).components.join('][') }]"
          end
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

        template :label do |key, text, options = {}|
          label(key, { for: field_id(key) }.merge(options)) {
            emit text
          }
        end

        template :text do |key, options = {}|
          input({
             type:  :text,
             name:  field_name(key),
             value: data.fetch(key, ""),
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