module Shopping
  class Cart
    class ItemView < Lucid::Component::Base
      prop :cart
      prop :item
      key { props.item.product_id }

      on(Cart::ItemChanged) do |event|
        element.replace if event[:product_id] == props.item.product_id
      end

      element :tr do |item|
        td item.product_name
        td item.quantity
        td Format.currency(item.price)
        td {
          button_to inc, "+"
          button_to dec, "-"
        }
      end

      def inc
        Cart::AddProduct[
           product_id: props.item.product_id,
           cart_id:    props.cart.id
        ]
      end

      def dec
        Cart::RemoveProduct[
           product_id: props.item.product_id,
           cart_id:    props.cart.id
        ]
      end
    end
  end
end