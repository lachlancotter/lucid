module MusicStore
  module ShoppingCart
    class CartView < Lucid::Component::Base
      param :open, Types.bool.default(false)
      to Open, open: true
      to Close, open: false

      use :cart, from: :session
      nest(:contents) { |cart| CartItemsListing[cart: cart] }
      nest(:item_count) { |cart| CartItemsCount[cart: cart] }

      element do |open|
        subview(:item_count)
        div(class: "cart") {
          link_to Open, "Open Cart" unless open
          link_to Close, "Close Cart" if open
          subview(:contents) if open
        }
      end
    end
  end
end