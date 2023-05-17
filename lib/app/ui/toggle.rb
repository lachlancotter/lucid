require "lucid/component"
require "lucid/state"

class Toggle < Lucid::Component
  class On < Lucid::State
    def self.render
      <<~HTML
        <p>
            <strong>ON</strong> | 
            <a href="/toggle/off">OFF</a>
        </p>
      HTML
    end
  end

  class Off < Lucid::State
    def self.render
      <<~HTML
        <p>
            <a href="/toggle/on">ON</a> | 
            <strong>OFF</strong>
        </p>
      HTML
    end
  end
end