require "lucid/form"

module Lucid
  class Button
    def initialize (endpoint, label)
      @endpoint = endpoint
      @label    = label
    end

    def template
      button_label = @label
      Form.new(@endpoint, {}).template do |f|
        f.submit(button_label)
      end
    end
  end
end