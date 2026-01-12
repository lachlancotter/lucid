module Lucid
  module State
    #
    # Scope access to parameters in a State::Store via coordinate-based 
    # namespacing and path depth tracking. Enables multiple components to 
    # share a single State::Store without clobbering each others data.
    # 
    class Scope
      def initialize (store, depth = 0, coordinate = [])
        @store      = store
        @depth      = depth
        @coordinate = coordinate
      end

      attr_reader :depth, :coordinate

      def descend (depth_offset, coordinate_element)
        new_coordinate = @coordinate + [coordinate_element]
        self.class.new(@store, @depth + depth_offset, new_coordinate)
      end

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

      # Adaptor methods. Can remove once we've refactored the map.

      # Can we get rid of this round about callback for reading/writing with maps?
      def read (map)
        {}.tap do |result|
          map.decode(self, result)
        end
      end
      
      def read_param (key)
        get_param(key)
      end

      def read_path_segment (n)
        get_segment(n)
      end

      def write_param (key, value)
        set_param(key, value)
      end

      def write_path_segment (key, value)
        set_segment(key, value)
      end

      private

      def qualify_key (key)
        if @coordinate.empty?
          key.to_s
        else
          "#{key}.#{@coordinate.join}"
        end
      end
    end
  end
end