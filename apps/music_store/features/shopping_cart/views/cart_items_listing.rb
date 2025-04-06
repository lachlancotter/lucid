module MusicStore
  module ShoppingCart
    class CartItemsListing < Lucid::Component::Base
      prop :cart, Types.instance(Cart)

      nest(:total_view) do |cart|
        CartTotalView[cart: cart]
      end

      nest(:item_views) do |cart|
        CartItemView.enum(cart.items) do |item|
          { item: item, cart: cart }
        end
      end

      on ItemAdded[quantity: 1] do |event|
        item_views.append(find_cart_item(event[:product_id]))
      end

      on ItemRemoved[quantity: 0] do |event|
        item_views.remove { |view| view.props.item.product_id == event[:product_id] }
      end

      def find_cart_item (product_id)
        props.cart.items.find { |item| item.product_id == product_id }
      end

      element do
        h2 "Your Cart"
        div {
          p "Product"
          p "Quantity"
          p "Price"
          p "Actions"
        }
        subviews(:item_views)
        subview(:total_view)
        p { link_to Checkout::Link, "Checkout" }
      end

    end
  end
end