module Lucid
  class Form
    def initialize (endpoint)
      @endpoint = endpoint
    end

    def to_s (&block)
      <<~HTML
        <form action="#{@endpoint.action_route}" method="#{@endpoint.action_method}">
          <input type="hidden" name="state" value="#{@endpoint.encode_state}" />
          <input type="hidden" name="action" value="#{@endpoint.action_name}" />
          #{block.call}
        </form>
      HTML
    end
  end
end