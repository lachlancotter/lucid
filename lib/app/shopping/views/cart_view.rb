module Shopping
  class CartView < Lucid::Component::Base
    param :open, default: "0"
    visit Cart::Open, open: "1"
    visit Cart::Close, open: "0"

    let(:cart) { Session.current.cart }
    let(:is_open) { |open| open == "1" }

    on(Cart::ItemChanged) { render.replace }

    # ===================================================== #
    #    Template
    # ===================================================== #

    template do |cart, is_open|
      div(class: "cart") {
        p cart.item_count
        emit Cart::Open.link("Open Cart") unless is_open
        emit Cart::Close.link("Close Cart") if is_open
        emit_template :contents, cart if is_open
      }
    end

    template :contents do |cart|
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
      p { emit Checkout::Link.link("Checkout") }
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

    # ===================================================== #
    #    Helpers
    # ===================================================== #

    def inc_button (item)
      Cart::AddProduct.button("+",
         product_id: item.product_id, cart_id: cart.id
      )
    end

    def dec_button (item)
      Cart::RemoveProduct.button("-",
         product_id: item.product_id, cart_id: cart.id
      )
    end

    def format_currency(amount)
      formatted_amount    = '%.2f' % amount.to_f
      integer, decimal    = formatted_amount.split('.')
      integer_with_commas = integer.chars.to_a.reverse.each_slice(3).map(&:join).join(',').reverse
      "$#{integer_with_commas}.#{decimal}"
    end

  end
end