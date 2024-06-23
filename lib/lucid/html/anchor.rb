module Lucid
  module HTML
    class Anchor
      def initialize (message, **opts, &block)
        @message = message
        @options = opts
        @block   = block
      end

      def template
        "<a href='#{href}'>#{@options[:text]}</a>"
      end

      def href
        @message.url
      end

      # def attrs
      #   {
      #      href: href,
      #      data: {
      #         lucid: {
      #            state: JSON.encode(@location.state.to_h)
      #         }
      #      }
      #   }
      # end
    end
  end
end