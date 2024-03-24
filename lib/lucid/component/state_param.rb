module Lucid
  module Component
    #
    # Provides a standard interface for reading state from
    # a Reader or Hash.
    #
    class StateParam
      def self.from (data)
        Check[data].type(Hash, FromHash, State::Reader)
        data.is_a?(Hash) ? FromHash.new(data) : data
      end

      class FromHash
        def initialize (hash)
          Check[hash].hash
          @hash = hash
        end

        # def [] (key)
        #   @hash[key]
        # end

        def read (map)
          @hash || {}
        end

        def seek (index, key)
          if @hash.key?(key)
            FromHash.new(@hash[key])
          else
            FromHash.new({})
          end
        end
      end
    end
  end
end