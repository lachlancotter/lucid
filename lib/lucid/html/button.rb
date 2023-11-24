require "lucid/html/form"

module Lucid
  module HTML
    class Button
      def initialize (command, label)
        @command = command
        @label   = label
      end

      def to_s
        template.render
      end

      def template
        button_label = @label
        Form.new(@command) do |f|
          emit f.submit(button_label)
        end.template
      end
    end
  end
end