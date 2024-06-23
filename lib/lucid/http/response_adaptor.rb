require "htmlbeautifier"

module Lucid
  module HTTP
    #
    # Wrapper around an HTTP response that provides an API to
    # set the response state and update components.
    #
    class ResponseAdaptor
      extend Forwardable

      def initialize (response)
        @response = response
      end

      def_delegators :@response,
         :status, :headers, :location, :body,
         :status=, :location=, :body=, :set_cookie

      def send_delta (component, htmx:)
        tap do
          if htmx
            send_htmx(component)
          else
            @response.redirect(component.url, 303)
          end
        end
      end

      def send_state (component)
        tap do
          self.location = component.url
          self.body     = HtmlBeautifier.beautify(component.render_full)
        end
      end

      def send_error (error)
        tap do
          self.status = 422
          self.body   = error.message
        end
      end

      private

      def send_htmx (component)
        component.changes.tap do |changes|
          if changes.empty?
            @response.status                 = 200
            @response.headers["HX-Push-Url"] = component.url
            @response.headers["HX-Reswap"]   = "none"
          else
            @response.status                 = 200
            @response.headers["HX-Push-Url"] = component.url
            @response.headers["HX-Retarget"] = changes.primary_target
            @response.headers["HX-Reswap"]   = changes.primary_swap
            @response.body                   = HtmlBeautifier.beautify(changes.to_s)
          end
        end
      end

    end
  end
end