module Shopping
  class Session
    class << self
      attr_accessor :current
    end

    def initialize (data)
      @data = data
    end

    attr_reader :data

    def [] (key)
      data[key]
    end

    def cart
      Cart.get(data[:cart_id])
    end
  end
end