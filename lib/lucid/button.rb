require "lucid/form"

module Lucid
  class Button
    def initialize (endpoint, label)
      @endpoint = endpoint
      @label    = label
    end

    def to_s
      Form.new(@endpoint).to_s do
        <<~HTML
          <button type="submit">#{@label}</button>
        HTML
      end
    end
  end
end