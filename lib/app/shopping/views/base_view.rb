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

    nest :content, match(:step,
       store:    StoreView,
       checkout: CheckoutView
    )

    # nest :content do |step|
    #   match(step) do
    #     is("store") { StoreView }
    #     is("checkout") { CheckoutView }
    #   end
    # end

    # ===================================================== #
    #    Template
    # ===================================================== #

    template do
      # head {
      #   link(rel: "stylesheet", href: "style.css")
      # }
      body {
        emit_template :branding
        emit_view :content
      }
    end

    template :branding do
      div(class: "branding") {
        h2 "Branding"
      }
    end

  end
end