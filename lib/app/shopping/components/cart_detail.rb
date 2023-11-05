require "app/shopping/events"
require "app/shopping/model/cart"

module Shopping
  class CartDetail < Lucid::Component
    config do
      option :cart, Cart.new
    end

    on CartItemChanged do |event|
      render :replace
    end

    def inc_button (item)
      AddProductToCart.button("+",
         product_id: item.product_id, cart_id: cart.id
      )
    end

    def dec_button (item)
      RemoveProductFromCart.button("-",
         product_id: item.product_id, cart_id: cart.id
      )
    end

    template do
      h2 "Cart"
      ul {
        cart.items.each do |item|
          li {
            p { text item.product_name }
            p { text item.quantity }
            p { text item.total }
            emit inc_button
            emit dec_button
          }
        end
      }
      p { text cart.total }
    end

  end
end