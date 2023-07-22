module Lucid
  class Link
    def initialize (route)
      @route = route
    end

    def text (string)
      "<a href='#{href}'>#{string}</a>"
    end

    def href
      @route.to_s
    end

    def attrs
      {
         href: href,
         data: {
            lucid: {
               state: JSON.encode(@route.state.to_h)
            }
         }
      }
    end
  end
end