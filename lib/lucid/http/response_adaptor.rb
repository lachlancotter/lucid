module Lucid
  module HTTP
    #
    # Wrapper around an HTTP response that provides an API to
    # set the response state and update components.
    #
    class ResponseAdaptor
      def initialize (response)
        @response = response
      end

      def send_delta (component)
        tap do
          self.status   = 303
          self.location = component.href
        end
      end

      def send_state (component)
        tap do
          self.location = component.href
          self.body     = component.render.replace.call
        end
      end

      def send_error (error)
        tap do
          self.status = 422
          self.body   = error.message
        end
      end

      def headers
        @response.headers
      end

      def status= (status)
        @response.status = status
      end

      def location= (location)
        @response.headers["Location"] = location.to_s
      end

      # Temporary. We should add a higher level API for setting
      # updated components.
      def body= (body)
        @response.body = body
      end
    end
  end
end