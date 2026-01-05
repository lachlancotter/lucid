module Lucid
  module State
    #
    # Cursors are used by Readers and Writers to access data in the
    # state buffer. State buffers (which are URLs) encode information in
    # a path and query string. Cursors are used to maintain the current
    # position in the path and query string. Cursors are immutable.
    #
    class Cursor
      def initialize (reader, path_index = 0, namespace = Namespace.new(""))
        @reader     = Types.instance(Reader)[reader]
        @path_index = Types.integer[path_index]
        @namespace  = Types.instance(Namespace)[namespace]
      end
      
      # ===================================================== #
      #    Moving the cursor
      # ===================================================== #

      def seek (path_index, namespace = @namespace)
        advance(path_index).scope(namespace)
      end
      
      #
      # Return a new Cursor with the path offset applied.
      #
      def advance (path_offset = 1)
        Cursor.new(@reader, @path_index + path_offset, @namespace)
      end

      #
      # Return a new cursor with the param key appended to the scope.
      #
      def scope (namespace)
        Cursor.new(@reader, @path_index, namespace)
      end
      
      # ===================================================== #
      #    Reading at the cursor
      # ===================================================== #

      def read (map)
        {}.tap do |state|
          Types.instance(State::Map)[map].decode(self, state)
        end
      end

      # 
      # Callback from the state map
      # 
      def read_path_segment (index)
        advance(index).segment
      end

      # 
      # Callback from the state map
      # 
      def read_param (key)
        param(key)
      end

      #
      # Return the path segment at the current index.
      #
      def segment
        @reader.path_segments[@path_index]
        # path[@path_index]
      end

      #
      # The data parameter is a hash of query parameters, which may
      # contain nested hashes. The key parameter is a symbol specifying
      # the key to extract from the data hash at the current param path.
      #
      def param (key)
        @reader.query_params[@namespace.qualify(key).to_sym]
        # data[@namespace.qualify(key).to_sym]
      end
    end
  end
end