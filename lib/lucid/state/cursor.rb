module Lucid
  module State
    #
    # Encapsulates a path position and query scope for state
    # readers and writers. Immutable.
    #
    class Cursor
      def initialize (path_index = 0, scope = Path.new)
        @path_index = path_index
        @scope      = scope
      end

      def advance (path_offset = 1)
        Cursor.new(@path_index + path_offset, @scope)
      end

      def scope (key)
        Cursor.new(@path_index, @scope.concat(key))
      end

      def segment (path)
        path[@path_index]
      end

      def param (data, key)
        @scope.inject(data) { |d, k| d[k] }[key]
      end
    end
  end
end