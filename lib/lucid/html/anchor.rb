module Lucid
  class Anchor
    def initialize (route, options = {}, &block)
      @route   = route
      @options = options
      @block   = block
    end

    def to_s
      "<a href='#{href}'>#{@options[:text]}</a>"
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