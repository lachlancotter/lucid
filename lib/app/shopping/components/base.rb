require "lucid/component/base"
require "app/shopping/components/store_component"
require "app/shopping/components/checkout_component"

module Shopping
  class Base < Lucid::Component::Base
    path :step, default: "store"

    validate do
      required(:step).
         filled(:string).
         value(included_in?: %w[store checkout])
    end

    nest :current_step, switch(:step,
       store:    StoreComponent,
       checkout: CheckoutComponent
    )

    visit Checkout do
      state.update(step: "checkout")
    end

    template do
      head {
        tag(:link, rel: "stylesheet", href: "style.css")
      }
      body {
        emit_template :branding
        emit_view :current_step
      }
    end

    template :branding do
      div(class: "branding") {
        h2 "Branding"
      }
    end

  end
end