module Lucid
  module State
    #
    # Read state from the URL string.
    #
    class Reader
      #
      # URL param includes a path and query string.
      #
      def initialize (url)
        @url                 = Types.string.constrained(min_size: 1)[url]
        @path, @query_string = @url.split("?")
      end

      def cursor
        Cursor.new(self)
      end

      def path_segments
        @path_segments ||= parse_path(@path)
      end

      def query_params
        @query_params ||= parse_query(@query_string)
      end

      private

      def parse_path (path)
        Types.string[path].sub(/^\//, "").split("/")
      end

      def parse_query (query_string)
        symbolize_keys(Rack::Utils.parse_nested_query(query_string))
      end

      def symbolize_keys(hash)
        hash.each_with_object({}) do |(key, value), result|
          result[key.to_sym] = value.is_a?(Hash) ?
             symbolize_keys(value) : value
        end
      end
    end

  end
end