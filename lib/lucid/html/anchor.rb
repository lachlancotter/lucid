module Lucid
  module HTML
    class Anchor
      def initialize (location, options = {}, &block)
        @location = location
        @options  = options
        @block    = block
      end

      def to_s
        "<a href='#{href}'>#{@options[:text]}</a>"
      end

      def href
        @location.to_s
      end

      def attrs
        {
           href: href,
           data: {
              lucid: {
                 state: JSON.encode(@location.state.to_h)
              }
           }
        }
      end
    end
  end
end