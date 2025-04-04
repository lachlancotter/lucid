module Lucid
  module State
    #
    # Provides an uniform interface for reading state from a Hash.
    #
    class HashReader
      def initialize (hash)
        @hash = Types.hash[hash].map do |k, v|
          [k.to_sym, v]
        end.to_h
      end

      def read (map)
        Types.instance(State::Map)[map]
        @hash.select do |k, _|
          map.rules.any? { |rule| rule.key == k }
        end
      end

      def seek (index, key)
        if @hash.key?(key)
          HashReader.new(@hash[key])
        else
          HashReader.new({})
        end
      end
    end
  end
end