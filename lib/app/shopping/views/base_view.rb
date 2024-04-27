module Shopping
  class BaseView < Lucid::Component::Base

    # ===================================================== #
    #    State
    # ===================================================== #

    path :page, default: "store"
    visit Product::Link, page: "store"
    visit Checkout::Link, page: "checkout"
    visit Admin::Link, page: "admin"

    # ===================================================== #
    #    Nests
    # ===================================================== #

    nest :content do |page|
      Match.on(page) do
        value("store") { StoreView }
        value("checkout") { CheckoutView }
        value("admin") { AdminView }
        value("denied") { NotAuthorizedView }
      end
    end

    nest(:status_nav) { StatusNav }
    nest(:login) { LoginView }

    on(Lucid::Guard::Denied) { update(page: "denied") }

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
          emit_template :header
          emit_view :content
          emit_view :login
        }
      }
    end

    template :header do
      div(class: "header") do
        emit_template :branding
        emit_view :status_nav
      end
    end

    template :branding do
      div(class: "branding") { h2 "Branding" }
    end

  end
end