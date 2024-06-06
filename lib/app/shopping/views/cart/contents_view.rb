module Shopping
  class Cart
    class ContentsView < Lucid::Component::Base
      prop :cart, Types.Instance(Cart)

      nest(:total_view) { |cart| TotalView[cart: cart] }
      nest(:item_views) do |cart|
        ItemView.enum(cart.items) do |item|
          { item: item, cart: cart }
        end
      end

      on Cart::ItemAdded do |event|
        ap props.cart
        if event[:quantity] == 1
          view = item_views.build(item_for_event(event))
          element.append(view, to: ".items")
        end
      end

      on Cart::ItemRemoved do |event|
        if event[:quantity] == 0
          view = item_views.for(item_for_event(event))
          element.remove(view)
        end
      end

      def item_for_event (event)
        props.cart.find(product_id: event[:product_id]).tap do |item|
          Types.Instance(CartItem)[item]
        end
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