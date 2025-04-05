module MusicStore
  module ShoppingCart
    class CartItemsCount < Lucid::Component::Base
      prop :cart, Types.instance(Cart)
      
      let(:item_count) { |cart| cart.item_count }
      on(ItemAdded) { invalidate(:item_count) }
      on(ItemRemoved) { invalidate(:item_count) }

      element do |item_count|
        div(class: "cart-items-count") {
          text item_count
        }
      end
    end
  end
end