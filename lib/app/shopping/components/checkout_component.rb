require "lucid/validation"

module Shopping
  class CheckoutComponent < Lucid::Component::Base
    nest :cart_view, CartDetail

    def cart
      Session.current.cart
    end

    on Lucid::Validation::Failed do |event|
      if event.message.is_a? SetShippingAddress
        # ap event.message.errors
        @invalid_set_shipping_address = event.message
      end
    end

    def form_params
      if @invalid_set_shipping_address
        @invalid_set_shipping_address.params
      else
        SetShippingAddress.new(cart_id: cart.id).params
      end
    end

    def validation_errors?
      !!@invalid_set_shipping_address
    end

    template :default do
      if cart.shipping_address.nil?
        emit_template :form
      else
        emit_template :complete
      end
    end

    template :form do
      div(class: "checkout") {
        h2 "Checkout"
        emit_view :cart_view
        emit SetShippingAddress.form(form_params) { |f|
          f.hidden(:cart_id)
          f.struct(:address) { |a|
            emit_template :form_field, a, :name
            emit_template :form_field, a, :street
            emit_template :form_field, a, :city
            emit_template :form_field, a, :state
            emit_template :form_field, a, :zip
          }
          f.submit!("Continue")
        }
      }
    end

    template :form_field do |form, field|
      p(class: validation_errors? && form.errors[field] ? "error" : nil) {
        form.label!(field, field.capitalize)
        form.text!(field)
        if validation_errors? && form.errors[field]
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