module MusicStore
  module ShoppingCart
    class CartView < Lucid::Component::Base
      param :open, Types.bool.default(false)
      visit Open, open: true
      visit Close, open: false

      use :cart, from: :session
      let(:item_count) { |cart| cart.item_count }
      nest(:contents) { CartItemsListView[cart: cart] }
      on(ItemAdded) { invalidate(:item_count) }

      element do |item_count, open|
        p item_count
        div(class: "cart") {
          link_to Open, "Open Cart" unless open
          link_to Close, "Close Cart" if open
          subview(:contents) if open
        }
      end
    end
  end
end