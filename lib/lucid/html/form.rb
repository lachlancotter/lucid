require "lucid/renderable"

module Lucid
  module HTML
    #
    # Build form elements.
    #
    class Form
      def initialize (command, &block)
        @command = command
        @block   = block
      end

      def to_s
        template.render
      end

      def template
        Papercraft.html do |command|
          form action: command.href, method: command.http_method do
            input type: :hidden, name: :state, value: command.encode_state
            input type: :hidden, name: :msg, value: command.message_name
            emit_yield Builder.new(command.params, self, Path.new(command.message_name))
          end
        end.apply(@command, &@block)
      end

      class Builder
        include Renderable

        def initialize (data, renderer, path = Path.new)
          raise "no data" unless data
          @data     = data
          @renderer = renderer
          @path     = path
        end

        attr_reader :data

        def emit (template)
          @renderer.emit(template)
        end

        def struct (name)
          yield Builder.new(
             @data.fetch(name, {}),
             @renderer,
             @path.concat(name)
          )
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

        def field_id (key)
          raise "invalid key: #{key}" unless key.is_a?(String) || key.is_a?(Symbol)
          @path.concat(key).join("_")
        end

        def field_name (key)
          if @path.depth == 0
            key.to_s
          else
            @path.head + "[#{ @path.tail.concat(key).components.join('][') }]"
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