require "lucid/component"
require "app/shopping/components/store_component"

module Shopping
  class Base < Lucid::Component

    nest :store, StoreComponent

    template do
      head {
        link(rel: "stylesheet", href: "style.css")
      }
      body {
        emit_template :branding
        emit_view :store
      }
    end

    template :branding do
      div(class: "branding") {
        h2 "Branding"
      }
    end

  end
end