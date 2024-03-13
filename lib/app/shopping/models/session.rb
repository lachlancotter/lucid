module Shopping
  class Session
    class << self
      attr_accessor :current
      def init
        self.current = new(cart_id: rand(50000))
      end
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