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
        find_cart_item(event[:product_id]).tap do |item|
          delta.append(item_views.build(item), to: ".items")
        end
      end

      on ItemRemoved[quantity: 0] do |event|
        find_cart_item_view(event[:product_id]).tap do |item_view|
          delta.remove(item_view) unless item_view.nil?
        end
      end
      
      def find_cart_item (product_id)
        props.cart.items.find { |item| item.product_id == product_id }
      end
      
      def find_cart_item_view (product_id)
        item_views.find { |view| view.props.item.product_id == product_id }
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