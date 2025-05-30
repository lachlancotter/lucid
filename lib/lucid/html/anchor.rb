module Lucid
  module HTML
    class Anchor
      def initialize (message, text = nil, **attrs, &block)
        @message = message
        @text    = text
        @block   = block
        @attrs   = attrs
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
        case @message
        when Message then @message.url
        when String then @message
        else raise ArgumentError, "Anchor received invalid message #{@message.class}"
        end
      end
    end
  end
end