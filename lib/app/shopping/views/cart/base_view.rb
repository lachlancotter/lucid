module Shopping
  class Cart
    class BaseView < Lucid::Component::Base
      param :open, default: "0"
      visit Cart::Open, open: "1"
      visit Cart::Close, open: "0"

      use :cart, from: :session
      let(:item_count) { |cart| cart.item_count }
      nest(:contents) { ContentsView[cart: cart] }

      element do |item_count, open|
        p item_count
        div(class: "cart") {
          link_to Cart::Open, "Open Cart" unless on(open)
          link_to Cart::Close, "Close Cart" if on(open)
          subview(:contents) if on(open)
        }
      end

      def on (value)
        value == "1"
      end
    end
  end
end