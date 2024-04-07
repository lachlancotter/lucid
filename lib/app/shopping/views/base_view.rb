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

    HTMX_LIB = {
       src:         "https://unpkg.com/htmx.org@1.9.11/dist/htmx.js",
       integrity:   "sha384-0gxUXCCR8yv9FM2b+U3FDbsKthCI66oH5IA9fHppQq9DDMHuMauqq1ZHBpJxQ0J0",
       crossorigin: "anonymous"
    }

    template do
      html(id: element_id) {
        head {
          script(HTMX_LIB)
        }
        body(HTMX[boost: true]) {
          emit_template :branding
          emit_view :content
        }
      }
    end

    template :branding do
      div(class: "branding") { h2 "Branding" }
    end

  end
end