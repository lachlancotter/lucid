module Shopping
  class Cart
    class BaseView < Lucid::Component::Base
      param :open, Types.bool.default(false)
      visit Cart::Open, open: true
      visit Cart::Close, open: false

      use :cart, from: :session
      let(:item_count) { |cart| cart.item_count }
      nest(:contents) { ContentsView[cart: cart] }
      on(Cart::ItemAdded) { invalidate(:item_count) }

      element do |item_count, open|
        p item_count
        div(class: "cart") {
          link_to Cart::Open, "Open Cart" unless open
          link_to Cart::Close, "Close Cart" if open
          subview(:contents) if open
        }
      end
    end
  end
end