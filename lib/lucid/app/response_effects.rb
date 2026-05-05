require "uri"

module Lucid
  class App
    #
    # Request-scoped response effects recorded by handlers.
    #
    class ResponseEffects
      class InvalidRedirect < ApplicationError
        def initialize (url)
          super("Invalid redirect URL: #{url.inspect}")
        end
      end

      class RedirectAlreadySet < ApplicationError
        def initialize (url)
          super("Redirect already set to #{url.inspect}")
        end
      end

      def redirect_to (url)
        raise RedirectAlreadySet.new(@redirect_url) if redirect?

        @redirect_url = validate_redirect_url(url)
      end

      def redirect?
        !@redirect_url.nil?
      end

      attr_reader :redirect_url

      private

      def validate_redirect_url (url)
        uri = URI.parse(Types.string[url])

        case uri
        when -> (value) { value.is_a?(URI::HTTP) || value.is_a?(URI::HTTPS) }
          uri.to_s
        else
          raise InvalidRedirect.new(url)
        end
      rescue URI::InvalidURIError, Dry::Types::ConstraintError
        raise InvalidRedirect.new(url)
      end
    end
  end
end
