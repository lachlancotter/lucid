module Lucid
  module State
    #
    # Provides an uniform interface for reading state from a Hash.
    #
    class HashReader
      attr_reader :hash

      def initialize (hash)
        @hash = flatten_hash(Types.hash[hash], Path.new([]))
      end

      def cursor (namespace = Namespace.new(""))
        Cursor.new(self, namespace)
      end

      def to_h
        @hash
      end

      private

      def flatten_hash (hash, root_path)
        PathEnumerator.new(hash, root_path).each_with_object({}) do |(path, key, value), result|
          if path.root?
            # Root level keys don't get namespaced
            result[key.to_sym] = value
          else
            namespace                    = Namespace.from_path(path)
            qualified_key                = namespace.qualify(key)
            result[qualified_key.to_sym] = value
          end
        end
      end

      #
      # Immutable cursor for reading from the hash with a specific namespace.
      #
      class Cursor
        def initialize (reader, namespace = Namespace.new(""))
          @reader    = reader
          @namespace = Types.instance(Namespace)[namespace]
        end

        attr_reader :namespace

        def read (map)
          Types.instance(State::Map)[map]
          {}.tap do |result|
            map.rules.each do |rule|
              qualified_key = @namespace.qualify(rule.key).to_sym
              if @reader.hash.key?(qualified_key)
                result[rule.key] = @reader.hash[qualified_key]
              end
            end
          end
        end

        def seek (index, namespace)
          namespace_obj = case namespace
          when Namespace then namespace
          when Symbol, String then Namespace.from_path(Path.new(namespace))
          else Types.instance(Namespace)[namespace]
          end
          Cursor.new(@reader, namespace_obj)
        end
      end

      #
      # Enumerates all paths through a nested hash structure,
      # yielding [path, key, value] tuples for each leaf node.
      #
      class PathEnumerator
        include Enumerable

        def initialize (hash, root_path)
          @hash      = hash
          @root_path = root_path
        end

        def each
          return enum_for(:each) unless block_given?
          enumerate(@hash, @root_path) { |item| yield item }
        end

        private

        def enumerate (hash, current_path, &block)
          hash.each do |key, value|
            if value.is_a?(Hash)
              # Recursively enumerate nested paths
              nested_path = current_path.concat(key)
              enumerate(value, nested_path, &block)
            else
              # Yield the path, key, and value for leaf nodes
              yield [current_path, key.to_sym, value]
            end
          end
        end
      end

    end
  end
end
