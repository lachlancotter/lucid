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
            @response.redirect(component.href, 303)
          end
        end
      end

      def send_state (component)
        tap do
          self.location = component.href
          self.body     = HtmlBeautifier.beautify(component.render(:replace).call)
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
        ChangeSet.new(component).tap do |change_set|
          if change_set.empty?
            @response.status                 = 200
            @response.headers["HX-Push-Url"] = component.href
            @response.headers["HX-Reswap"]   = "none"
          else
            @response.status                 = 200
            @response.headers["HX-Push-Url"] = component.href
            @response.headers["HX-Retarget"] = change_set.target
            @response.headers["HX-Reswap"]   = "outerHTML"
            @response.body                   = HtmlBeautifier.beautify(change_set.to_s)
          end
        end
      end

      #
      # Format the set of changed components for HTMX.
      #
      class ChangeSet
        def initialize (component)
          @component = component
        end

        def empty?
          branches.empty?
        end

        def branches
          @component.render.branches
        end

        def target
          "##{branches.first.element_id}"
        end

        def to_s
          head + tail.join("\n")
        end

        #
        # The first component is the main element to target.
        #
        def head
          branches.first.call(id: branches.first.element_id)
        end

        #
        # Additional components are updated via swap-oob.
        #
        def tail
          branches[1..-1].map do |branch|
            branch.call(HTMX.oob.merge(id: branch.element_id))
          end
        end
      end

    end
  end
end