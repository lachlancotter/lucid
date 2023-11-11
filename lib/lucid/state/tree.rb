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
      def initialize (data, context)
        @state  = context.build_state(data)
        @nested = context.nested.map do |key, component|
          [key, Tree.new(data[key] || {}, component)]
        end.to_h
      end

      attr_reader :state

      def [] (key)
        @nested[key]
      end

      #
      # Pass one or more symbols describing a path through the tree.
      #
      def nested (*keys)
        raise "No keys given" if keys.empty?
        keys.inject(@nested) { |memo, key| memo[key] }
      end
    end
  end
end