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