module Shopping
  class BaseView < Lucid::Component::Base
    path :page, Types.string.default("store".freeze)

    on(Lucid::Guard::Denied) { update(page: "denied") }
    visit Product::Link, page: "store"
    visit Checkout::Link, page: "checkout"
    visit Admin::Link, page: "admin"

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

    # ===================================================== #
    #    Template
    # ===================================================== #

    element do
      html {
        head {
          link_stylesheet("/style.css")
          script(HTMX::LIB)
          script(
            <<~JS
              document.addEventListener("htmx:afterRequest", function (event) {
                console.log("afterRequest");
                console.log(event.detail.xhr.response);
              });
            JS
          )
        }
        body(HTMX.boost) {
          fragment :header
          subview :content
          subview :login
        }
      }
    end

    template :header do
      div(class: "header") do
        fragment :branding
        subview :status_nav
      end
    end

    template :branding do
      div(class: "branding") { h2 "Branding" }
    end

  end
end