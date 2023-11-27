require "lucid/component/base"
require "app/shopping/components/store_component"
require "app/shopping/components/checkout_component"

module Shopping
  class Base < Lucid::Component::Base
    href { path :step; nest :store }

    state do
      attribute :step, default: "store"
    end

    nest :store, StoreComponent
    nest :checkout, CheckoutComponent

    visit Checkout do |link|
      state.update(step: "checkout")
    end

    template do
      head {
        link(rel: "stylesheet", href: "style.css")
      }
      body {
        emit_template :branding
        if state[:step] == "store"
          emit_view :store
        else
          emit_view :checkout
        end
      }
    end

    template :branding do
      div(class: "branding") {
        h2 "Branding"
      }
    end

  end
end