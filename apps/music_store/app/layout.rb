module MusicStore
  class Layout < Lucid::Component::Base
    route "/:page", nest: :content
    param :page, Types.string.default("store".freeze)

    visit Catalogue::Link, page: "store"
    visit Checkout::Link, page: "checkout"
    visit Admin::Link, page: "admin"

    nest :content do |page|
      Match.on(page) do
        value("store") { Catalogue::Layout }
        value("checkout") { Checkout::Layout }
        value("admin") { Admin::Layout }
      end
    end

    nest(:status_nav) { Authentication::StatusNav }
    nest(:login) { Authentication::LoginView }

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