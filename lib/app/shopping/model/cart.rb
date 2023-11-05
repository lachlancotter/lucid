module Shopping
  class Cart
    def self.current

    end

    def initialize
      @items = []
    end

    attr_reader :items

    def total
      0
    end
  end
end