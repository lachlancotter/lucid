module MusicStore
  module ShoppingCart
    class CartItemsListing < Lucid::Component::Base
      prop :cart, Types.Instance(Cart)

      nest(:total_view) { |cart| CartTotalView[cart: cart] }

      nest(:item_views) do |cart|
        CartItemView.enum(cart.items) do |item|
          { item: item, cart: cart }
        end
      end

      # nest(:item_views) do |cart|
      #   enum(cart.items) { |item| CartItemView[item: item, cart: cart] }
      # end

      # enum(:item_views) do |cart|
      #   cart.items.map { |item| CartItemView[item: item, cart: cart] }
      # end

      on ItemAdded[quantity: 1] do |event|
        item = find_cart_item(event[:product_id])
        view = item_views.build(item)
        delta.append(view, to: ".items")
      end

      on ItemRemoved[quantity: 0] do |event|
        item = find_cart_item(event[:product_id])
        view = item_views.for(item)
        delta.remove(view)
      end

      def find_cart_item (product_id)
        props.cart.find(product_id: product_id)
      end

      element do
        h2 "Your Cart"
        div {
          p "Product"
          p "Quantity"
          p "Price"
          p "Actions"
        }
        div(class: "items") {
          item_views.each { |item| subview(item) }
        }
        subview(:total_view)
        p { link_to Checkout::Link, "Checkout" }
      end

    end
  end
end