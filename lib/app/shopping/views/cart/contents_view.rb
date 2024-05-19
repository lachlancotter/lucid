module Shopping
  class Cart
    class ContentsView < Lucid::Component::Base
      prop :cart

      nest(:total_view) { |cart| TotalView[cart: cart] }
      nest(:item_views) do |cart|
        ItemView.enum(cart.items) do |item|
          { item: item, cart: cart }
        end
      end

      on Cart::ItemAdded do |event|
        if event[:quantity] == 1
          cart_item = cart.find(product_id: event[:product_id])
          view      = item_views.build(cart_item)
          element.append(view, to: ".table")
        end
      end

      on Cart::ItemRemoved do |event|
        if event[:quantity] == 0
          cart_item = cart.find(product_id: event[:product_id])
          view      = item_views.for(cart_item)
          element.remove(view)
        end
      end

      element do
        h2 "Your Cart"
        table {
          tr {
            th "Product"
            th "Quantity"
            th "Price"
            th "Actions"
          }
          item_views.each { |item| subview(item) }
        }
        subview(:total_view)
        p { link_to Checkout::Link, "Checkout" }
      end

    end
  end
end