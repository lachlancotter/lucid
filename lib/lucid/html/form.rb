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
            emit_yield Builder.new(command.params, self)
          end
        end.apply(@command, &@block)
      end

      class Builder
        include Renderable

        def initialize (data, renderer)
          raise "no data" unless data
          @data     = data
          @renderer = renderer
        end

        attr_reader :data

        def emit (template)
          @renderer.emit(template)
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

        # def label (field_name, text, options = {})
        #   template(:label).render(field_name, text, options)
        # end
        #
        # def text (field_name, options = {})
        #   template(:text).render(field_name, options)
        # end
        #
        # def submit (label)
        #   template(:submit).render(label)
        # end

        template :label do |field_name, text, options = {}|
          label(field_name.capitalize, { for: field_name }.merge(options)) {
            emit text
          }
        end

        template :text do |field_name, options = {}|
          input({
             type:  :text,
             name:  field_name,
             value: data.fetch(field_name, ""),
             id:    field_name
          }.merge(options))
        end

        template :submit do |label|
          input type: :submit, value: label
        end
      end
    end
  end
end