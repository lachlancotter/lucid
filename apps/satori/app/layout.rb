module Satori
  module Booking
    class Layout < Lucid::Component::Base
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
    end
  end
end