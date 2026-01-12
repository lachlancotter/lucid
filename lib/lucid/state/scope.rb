module Lucid
  module State
    #
    # Scope access to parameters in a State::Store via namespacing and 
    # path depth tracking. Enables multiple components to share a single
    # State::Store without clobbering each others data.
    # 
    class Scope
      def initialize (store, depth = 0, namespace = nil)
        @store     = store
        @depth     = depth
        @namespace = namespace
      end

      def descend (depth_offset, namespace)
        self.class.new(@store, @depth + depth_offset, namespace)
      end

      attr_reader :depth, :namespace
      
      def get_segment (n)
        @store.get_segment(@depth + n)
      end

      def set_segment (n, value)
        @store.set_segment(@depth + n, value)
      end

      def get_param (key)
        @store.get_param(qualify_key(key))
      end

      def set_param (key, value)
        @store.set_param(qualify_key(key), value)
      end

      private

      def qualify_key (key)
        if @namespace && !@namespace.empty?
          "#{key}.#{@namespace}"
        else
          key
        end
      end
    end
  end
end