module Lucid
  module HTML
    class Anchor
      def initialize (message, text:, &block)
        @message = message
        @text    = text
        @block   = block
      end

      def template
        Papercraft.html do |href, link_text, attrs, block|
          a(attrs.merge(href: href)) do
            text link_text unless block
            block.call if block
          end
        end.apply(href, @text, @attrs, @block)
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