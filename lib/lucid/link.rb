module Lucid
  class Link
    def initialize (state, text)
      @state = state
      # @route = Route.for(state)
    end

    # def initialize (route, text)
    #   @route = route
    #   @text = text
    # end

    def to_s
      "<a href='#{href}'>#{@text}</a>"
    end

    def href
      @route
    end

    def route
      Route.for(state, config)
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