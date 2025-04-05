module MusicStore
  module ShoppingCart
    class CartItemView < Lucid::Component::Base
      prop :cart, Types.instance(Cart)
      prop :item, Types.instance(CartItem)
      let(:product_id) { |item| item.product_id }
      key { product_id }

      on(ItemChanged[:product_id]) { delta.replace }

      element :div do |item|
        p item.product_name
        p item.quantity
        p Format.currency(item.price)
        p {
          button_to AddProduct.new(data_for(item)), "+"
          button_to RemoveProduct.new(data_for(item)), "-"
        }
      end
      
      def data_for (item)
        {
           product_id: item.product_id,
           cart_id:    props.cart.id
        }
      end
    end
  end
end