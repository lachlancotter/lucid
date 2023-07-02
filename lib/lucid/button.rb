module Lucid
  class Button
    def initialize (endpoint, label)
      @endpoint = endpoint
      @label    = label
    end

    def to_s
      <<~HTML
        <form action="#{@endpoint.action_route}">
          <button type="submit">#{@label}</button>
        </form>
      HTML
    end
  end
end