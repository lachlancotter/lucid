require "base64"

module Lucid
  module HTTP
    #
    # API for reading and writing data from/to cookies.
    #
    class Cookie
      BLANK = Base64.encode64("{}")

      def initialize (cookie_name, data = {})
        @cookie_name = cookie_name
        @data        = Match.on(data) do
          type(Hash) { data }
          type(String) { decode(data) }
        end
      end

      # ===================================================== #
      #    Data
      # ===================================================== #

      def [] (key)
        @data[key.to_s]
      end

      def []= (key, value)
        @data[key.to_s] = value
      end

      def to_h
        @data.map { |k, v| [k.to_sym, v] }.to_h
      end

      # ===================================================== #
      #    Read/Write
      # ===================================================== #

      def read (request)
        @data = decode(request.cookies.fetch(@cookie_name, BLANK))
      end

      def write (response)
        response.set_cookie(@cookie_name, { value: encode(@data), path: "/" })
      end

      # ===================================================== #
      #    Encode/Decode
      # ===================================================== #

      def encode (hash = @data)
        Base64.encode64(JSON.generate(hash))
      end

      def decode (string)
        JSON.parse(Base64.decode64(string))
      end
    end
  end
end