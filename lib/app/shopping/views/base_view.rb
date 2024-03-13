module Shopping
  class BaseView < Lucid::Component::Base

    # ===================================================== #
    #    State
    # ===================================================== #

    path :step, default: "store"
    visit Product::Link, step: "store"
    visit Checkout::Link, step: "checkout"

    # ===================================================== #
    #    Nests
    # ===================================================== #

    nest :current_step, match(:step,
       store:    StoreView,
       checkout: CheckoutView
    )

    # nest :current_step do
    #   state.match do
    #     step("store") { StoreView }
    #     step("checkout") { CheckoutView }
    #   end
    # end

    # ===================================================== #
    #    Template
    # ===================================================== #

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