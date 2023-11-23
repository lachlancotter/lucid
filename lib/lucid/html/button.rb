require "lucid/html/form"

module Lucid
  module HTML
    class Button
      def initialize (command, label)
        @command = command
        @label   = label
      end

      def to_s
        button_label = @label
        Form.new(@command, @command.params).template do |f|
          f.submit(button_label)
        end.render
      end
    end
  end
end