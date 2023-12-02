require "app/shopping/events"
require "app/shopping/model/cart"

module Shopping
  class CartDetail < Lucid::Component::Base

    def cart
      Session.current.cart
    end

    on CartItemChanged do |event|
      render
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
      div(class: "cart") {
        p cart.item_count
        h2 "Your Cart"
        table {
          tr {
            th "Product"
            th "Quantity"
            th "Price"
            th "Actions"
          }
          cart.items.each do |item|
            emit_template :item, item
          end
        }
        p { format_currency(cart.total) }
        p { emit Checkout.link("Checkout") }
      }
    end

    template :item do |item|
      tr {
        td item.product_name
        td item.quantity
        td format_currency(item.price)
        td {
          emit inc_button(item)
          emit dec_button(item)
        }
      }
    end

    def format_currency(amount)
      formatted_amount    = '%.2f' % amount.to_f
      integer, decimal    = formatted_amount.split('.')
      integer_with_commas = integer.chars.to_a.reverse.each_slice(3).map(&:join).join(',').reverse
      "$#{integer_with_commas}.#{decimal}"
    end

  end
end