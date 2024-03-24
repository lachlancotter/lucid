module Lucid
  module State
    #
    # Provides an uniform interface for reading state from a Hash.
    #
    class HashReader
      def initialize (hash)
        Check[hash].hash
        @hash = hash.map { |k, v| [k.to_sym, v] }.to_h
      end

      # def [] (key)
      #   @hash[key]
      # end

      def read (map)
        @hash || {}
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