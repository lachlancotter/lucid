module Lucid
  module State
    #
    # Read state from the URL string.
    #
    class Reader
      #
      # URL param includes a path and query string.
      #
      def initialize (url, cursor = Cursor.new)
        @url    = Types.string.constrained(min_size: 1)[url]
        @cursor = cursor
      end

      #
      # Read a hash of values from the URL based on the mapping rules.
      #
      def read (map)
        Types.instance(State::Map)[map]
        {}.tap { |state| map.decode(self, state) }
      end

      #
      # Returns a reader for the nested scope.
      #
      def seek (path_index, scope_key)
        Reader.new(@url, @cursor.advance(path_index).scope(scope_key))
      end

      def read_path_segment (index)
        @cursor.advance(index).segment(path_segments)
      end

      def read_param (key)
        @cursor.param(query_params, Types.symbol[key])
      end

      def with_scope (key)
        yield(
           Reader.new(@url, @cursor.scope(key))
        )
      end

      def path_segments
        parse_path(path)
      end

      def query_params
        parse_query(query_string)
      end

      def path
        Types.string[@url.split("?").first]
      end

      def query_string
        @url.split("?").last
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