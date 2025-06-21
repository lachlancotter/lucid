module MusicStore
  module Checkout
    class Layout < Lucid::Component::Base
      use :cart, from: :session
      nest(:cart_view) { ShoppingCart::CartView }
      echo(:shipping_address, SetShippingAddress) { |f| f.or_default(form_defaults) }

      def form_defaults
        {
           cart_id: cart.id,
           address: {
              name:   "",
              street: "",
              city:   "",
              state:  "",
              zip:    ""
           }
        }
      end

      # ===================================================== #
      #   Template
      # ===================================================== #

      element do |shipping_address, cart|
        div(class: 'checkout') {
          if cart.shipping_address.nil?
            fragment(:form, shipping_address)
          else
            fragment(:complete, cart)
          end
        }
      end

      template :form do |shipping_address|
        h2 "Checkout"
        subview(:cart_view)
        form_for(shipping_address) { |f|
          f.hidden(:cart_id)
          f.scoped(:address) { |a|
            fragment(:form_field, a, :name)
            fragment(:form_field, a, :street)
            fragment(:form_field, a, :city)
            fragment(:form_field, a, :state)
            fragment(:form_field, a, :zip)
          }
          f.submit("Continue")
        }
      end

      template :form_field do |form, field|
        p(class: form.errors(field).any? ? "error" : nil) {
          form.label(field, field.capitalize)
          form.text(field)
          form.errors(field).each { |error| span(error, class: "error") }
        }
      end

      template :complete do |cart|
        h2 "Checkout"
        p "Thank you for your order!"
        p {
          text cart.shipping_address[:name]
          br
          text cart.shipping_address[:street]
          br
          text format_address_line_2(cart.shipping_address)
        }
      end

      def format_address_line_2 (address)
        "#{address[:city]}, #{address[:state]} #{address[:zip]}"
      end

    end
  end
end