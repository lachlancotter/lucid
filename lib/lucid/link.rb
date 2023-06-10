module Lucid
  class Link
    def initialize (state, routes)
      @state = state
      @routes = routes
    end

    def text (string)
      "<a href='#{href}'>#{string}</a>"
    end

    def href
      @routes.encode(@state)
    end

    def attrs
      {
         href: href,
         data: {
            lucid: {
               state: JSON.encode(state.to_h)
            }
         }
      }
    end
  end
end