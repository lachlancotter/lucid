module MusicStore
  module Checkout
    class Layout < Lucid::Component::Base
      use :cart, from: :session
      nest(:cart_view) { ShoppingCart::CartView }
      echo SetShippingAddress, as: :shipping_address do
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

      element do |shipping_address|
        if cart.shipping_address.nil?
          fragment(:form, shipping_address)
        else
          fragment(:complete)
        end
      end

      template :form do |shipping_address|
        div(class: "checkout") {
          h2 "Checkout"
          subview(:cart_view)
          form_for(shipping_address) { |f|
            emit f.hidden(:cart_id)
            f.scoped(:address) { |a|
              fragment(:form_field, a, :name)
              fragment(:form_field, a, :street)
              fragment(:form_field, a, :city)
              fragment(:form_field, a, :state)
              fragment(:form_field, a, :zip)
            }
            emit f.submit("Continue")
          }
        }
      end

      template :form_field do |form, field|
        p(class: form.errors(field).any? ? "error" : nil) {
          emit form.label(field, field.capitalize)
          emit form.text(field)
          form.errors(field).each { |error| span(error, class: "error") }
        }
      end

      template :complete do
        div(class: "checkout") {
          h2 "Checkout"
          p "Thank you for your order!"
          p {
            text cart.shipping_address[:name]
            br
            text cart.shipping_address[:street]
            br
            text format_address_line_2(cart.shipping_address)
          }
        }
      end

      def format_address_line_2 (address)
        "#{address[:city]}, #{address[:state]} #{address[:zip]}"
      end

    end
  end
end