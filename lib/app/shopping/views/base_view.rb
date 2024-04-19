module Shopping
  class BaseView < Lucid::Component::Base

    # ===================================================== #
    #    State
    # ===================================================== #

    path :step, default: "store"
    visit Product::Link, step: "store"
    visit Checkout::Link, step: "checkout"

    # ===================================================== #
    #    Data
    # ===================================================== #

    let(:cart) { Session.current.cart }

    # ===================================================== #
    #    Nests
    # ===================================================== #

    nest :content do |step|
      Match.on(step) do
        value("store") { StoreView }
        value("checkout") { CheckoutView }
      end
    end

    # ===================================================== #
    #    Template
    # ===================================================== #

    template do
      html {
        head {
          link_stylesheet("/style.css")
          script(HTMX::LIB)
          # script(
          #   <<~JS
          #     document.addEventListener("htmx:afterRequest", function (event) {
          #       console.log("afterRequest");
          #       console.log(event.detail.xhr.response);
          #     });
          #   JS
          # )
        }
        body(HTMX.boost) {
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