module Lucid
  #
  # Build form elements.
  #
  class Form
    def initialize (command, data)
      @command = command
      @data    = data
    end

    def template (&block)
      Papercraft.html do |command, data|
        form action: command.href, method: command.http_method do
          input type: :hidden, name: :state, value: command.encode_state
          input type: :hidden, name: :command, value: command.class.name
          emit_yield Builder.new(data, self)
        end
      end.apply(@command, @data, &block)
    end

    class Builder
      def initialize (data, renderer)
        @data     = data
        @renderer = renderer
      end

      def label (field_name, options = {})
        proc = Papercraft.html do |name|
          label(field_name.capitalize, { for: name }.merge(options))
        end.apply(field_name)
        @renderer.emit proc
      end

      def text (field_name, options = {})
        proc = Papercraft.html do |name, value|
          input({ type: :text, name: name, value: value, id: name }.merge(options))
        end.apply(field_name, @data.fetch(field_name, ""))
        @renderer.emit proc
      end

      def submit (label)
        proc = Papercraft.html do |l|
          input type: :submit, value: l
        end.apply(label)
        @renderer.emit proc
      end
    end
  end
end