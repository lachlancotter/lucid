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

      def scoped
        HashScope.new(self)
      end

      # def cursor (namespace = Namespace.new(""))
      #   Cursor.new(self, namespace)
      # end

      def get_param (key)
        @hash[key.to_s]
      end

      def set_param (key, value)
        @hash[key.to_s] = value
      end

      def key? (key)
        @hash.key?(key.to_s)
      end

      class HashScope < Scope
        # Map all params to the hash, not the path.
        def read (map)
          {}.tap do |result|
            map.rules.each do |rule|
              qualified_key = qualify_key(rule.key)
              if @store.key?(qualified_key)
                result[rule.key] = @store.get_param(qualified_key)
              end
            end
          end
        end
      end

      def to_h
        @hash
      end

      private

      def flatten_hash (hash, root_path)
        CoordinateEnumerator.new(hash).each_with_object({}) do |(coordinate, key, value), result|
          if coordinate.empty?
            # Root level keys don't get qualified
            result[key.to_s] = value
          else
            # Qualify with coordinate string representation
            qualified_key         = "#{key}.#{coordinate.join}"
            result[qualified_key] = value
          end
        end
      end
      
      #
      # Enumerates all coordinates through a nested hash structure,
      # yielding [coordinate, key, value] tuples for each leaf node.
      # Coordinates are arrays of integers representing the index of
      # each hash key at each nesting level.
      #
      class CoordinateEnumerator
        include Enumerable

        def initialize (hash)
          @hash = hash
        end

        def each
          return enum_for(:each) unless block_given?
          enumerate(@hash, []) { |item| yield item }
        end

        private

        def enumerate (hash, current_coordinate, &block)
          hash.each_with_index do |(key, value), index|
            if value.is_a?(Hash)
              # Recursively enumerate nested coordinates
              nested_coordinate = current_coordinate + [index]
              enumerate(value, nested_coordinate, &block)
            else
              # Yield the coordinate, key, and value for leaf nodes
              yield [current_coordinate, key.to_sym, value]
            end
          end
        end
      end

    end
  end
end
