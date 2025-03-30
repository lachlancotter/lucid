module MusicStore
  module ShoppingCart
    class CartItemView < Lucid::Component::Base
      prop :cart, Types.Instance(Cart)
      prop :item, Types.Instance(CartItem)
      key { props.item.product_id }

      on(ItemChanged) do |event|
        element.replace if event[:product_id] == props.item.product_id
      end

      element :div do |item|
        p item.product_name
        p item.quantity
        p Format.currency(item.price)
        p {
          button_to inc, "+"
          button_to dec, "-"
        }
      end

      def inc
        AddProduct.new(
           product_id: props.item.product_id,
           cart_id:    props.cart.id
        )
      end

      def dec
        RemoveProduct.new(
           product_id: props.item.product_id,
           cart_id:    props.cart.id
        )
      end
    end
  end
end