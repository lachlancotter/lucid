require "checked"

module Lucid
  module Component
    #
    # Provides a standard interface for reading state from
    # a Reader or Hash.
    #
    class StateParam
      extend Checked

      def self.from (data)
        check(data).type(Hash, FromHash, State::Reader)
        data.is_a?(Hash) ? FromHash.new(data) : data
      end

      class FromHash
        include Checked

        def initialize (hash)
          check(hash).hash
          @hash = hash
        end

        # def [] (key)
        #   @hash[key]
        # end

        def read (map)
          @hash || {}
        end

        def seek (index, key)
          check(@hash).has_key(key)
          FromHash.new(@hash[key])
        end
      end
    end
  end
end