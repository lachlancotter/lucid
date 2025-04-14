module Lucid
  module State
    #
    # Cursors are used by Readers and Writers to access data in the
    # state buffer. State buffers (which are URLs) encode information in
    # a path and query string. Cursors are used to maintain the current
    # position in the path and query string. Cursors are immutable.
    #
    class Cursor
      def initialize (path_index = 0, param_path = Path.new)
        @path_index = path_index
        @param_path = param_path
      end

      #
      # Return a new Cursor with the path offset applied.
      #
      def advance (path_offset = 1)
        Cursor.new(@path_index + path_offset, @param_path)
      end

      #
      # Return a new cursor with the param key appended to the scope.
      #
      def scope (key)
        Cursor.new(@path_index, @param_path.concat(key))
      end

      #
      # Return the path segment at the current index.
      #
      def segment (path)
        path[@path_index]
      end

      #
      # The data parameter is a hash of query parameters, which may
      # contain nested hashes. The key parameter is a symbol specifying
      # the key to extract from the data hash at the current param path.
      #
      def param (data, key)
        nested_hash_at_path(data).fetch(key) { nil }
      end

      private

      #
      # Fetch the nested hash at the current param path. If any intermediate
      # keys are missing, an empty hash is returned.
      #
      def nested_hash_at_path (data)
        @param_path.inject(data) { |d, k| d.fetch(k.to_sym) { Hash.new } }
      end
    end
  end
end