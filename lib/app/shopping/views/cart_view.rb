module Shopping
  class CartView < Lucid::Component::Base
    param :open, default: "0"
    visit Cart::Open, open: "1"
    visit Cart::Close, open: "0"

    use :cart, from: :session
    let(:is_open) { |open| open == "1" }
    on(Cart::ItemChanged) { render.replace }

    # ===================================================== #
    #    Template
    # ===================================================== #

    template do |cart, is_open|
      p cart.item_count
      div(class: "cart") {
        link_to Cart::Open, "Open Cart" unless is_open
        link_to Cart::Close, "Close Cart" if is_open
        fragment(:contents, cart) if is_open
      }
    end

    template :contents do |cart|
      h2 "Your Cart"
      table {
        fragment :header
        cart.items.each { |item|
          fragment(:item, item, cart)
        }
      }
      p { format_currency(cart.total) }
      p { link_to Checkout::Link, "Checkout" }
    end

    template :header do
      tr {
        th "Product"
        th "Quantity"
        th "Price"
        th "Actions"
      }
    end

    template :item do |item, cart|
      tr {
        td item.product_name
        td item.quantity
        td format_currency(item.price)
        td {
          button_to add_product(item, cart), "+"
          button_to remove_product(item, cart), "-"
        }
      }
    end

    # ===================================================== #
    #    Helpers
    # ===================================================== #

    def add_product (item, cart)
      Cart::AddProduct.new(product_id: item.product_id, cart_id: cart.id)
    end

    def remove_product (item, cart)
      Cart::RemoveProduct.new(product_id: item.product_id, cart_id: cart.id)
    end

    def format_currency(amount)
      formatted_amount    = '%.2f' % amount.to_f
      integer, decimal    = formatted_amount.split('.')
      integer_with_commas = integer.chars.to_a.reverse.each_slice(3).map(&:join).join(',').reverse
      "$#{integer_with_commas}.#{decimal}"
    end

  end
end