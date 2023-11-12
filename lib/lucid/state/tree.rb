require "immutable/hash"

module Lucid
  module State
    #
    # Tree structure of State objects corresponding to the hierarchy
    # of nested components. Used to track the state of the application
    # globally.
    #
    class Tree
      #
      # data
      #   Hash of data to build the tree from.
      # context
      #   Stateful, Nestable object used to build states and nesting keys.
      #
      def initialize (data, context = nil)
        @data = data.is_a?(Immutable::Hash) ? data :
           Immutable::Hash[
              Tree.accumulate(data, context, path)
           ]
      end

      #
      # Accumulate an array of key-value pairs to construct the
      # internal tree structure.
      #
      def self.accumulate (data, context, path, pairs = [])
        pairs.tap do
          pairs.push([path.to_key, context.build_state(data)])
          context.nested.each do |key, component|
            Tree.accumulate(data[key] || {}, component, path.concat(key), pairs)
          end
        end
      end

      #
      # Rebuild a hash of nested component states from the tree.
      #
      def to_h
        {}.tap do |result|
          @data.keys.each do |path|
            if path == "/"
              result.merge!(@data.get(path).to_h)
            else
              path_keys             = path.split(".").map(&:to_sym)
              last_key              = path_keys.pop
              nested_hash           = path_keys.inject(result) { |h, k| h[k] ||= {} }
              nested_hash[last_key] = @data.get(path).to_h
            end
          end
        end
      end

      def root
        path
      end

      def path (*keys)
        Path.new(self, keys)
      end

      # Used by Path.
      def get (key)
        @data.get(key)
      end

      # Used by Path.
      def put (key, &block)
        @data.put(key, &block)
      end

      class Path
        def initialize (tree, keys)
          @tree = tree
          @keys = keys
        end

        def inspect
          "<#{self.class.name} #{to_key}>"
        end

        def to_key
          @keys.any? ? @keys.join(".") : "/"
        end

        def concat (key)
          Path.new(@tree, @keys + [key])
        end

        def get
          @tree.get(to_key)
        end

        #
        # Yields a copy of the state at this path to the block along
        # with any additional arguments. The block should modify the
        # state using the update() method. The updated state is then
        # inserted into a new Tree, which is the return value of
        # the method. Does not modify the original tree.
        #
        def transform (*args, &block)
          Tree.new(
             @tree.put(to_key) do |state|
               raise "No state found at #{to_key}" unless state
               state.transform(*args, &block)
             end
          )
        end
      end
    end
  end
end