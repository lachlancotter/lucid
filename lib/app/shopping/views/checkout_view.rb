module Shopping
  class CheckoutView < Lucid::Component::Base
    use :cart, from: :session
    nest(:cart_view) { CartView }
    echo(Order::SetShippingAddress, as: :address) { { cart_id: cart.id } }

    # ===================================================== #
    #   Template
    # ===================================================== #

    template do
      if cart.shipping_address.nil?
        fragment :form
      else
        fragment :complete
      end
    end

    template :form do
      div(class: "checkout") {
        h2 "Checkout"
        subview :cart_view
        form_for Order::SetShippingAddress[address_params] do |f|
          f.hidden(:cart_id)
          f.struct(:address) { |a|
            fragment(:form_field, a, :name)
            fragment(:form_field, a, :street)
            fragment(:form_field, a, :city)
            fragment(:form_field, a, :state)
            fragment(:form_field, a, :zip)
          }
          f.submit!("Continue")
        end
      }
    end

    template :form_field do |form, field|
      p(class: address_errors? && form.errors[field] ? "error" : nil) {
        form.label!(field, field.capitalize)
        form.text!(field)
        if address_errors? && form.errors[field]
          form.errors[field].each do |error|
            span(class: "error") { text error }
          end
        end
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