require "app/shopping/model/cart_item"

module Shopping
  class Cart
    def self.current
      @cart ||= Cart.new
    end

    def initialize
      @items = []
      @id = 1
    end

    attr_reader :items, :id

    def add_product (product)
      item = @items.find { |item| item.product_id == product.id }
      if item.nil?
        @items << CartItem.new(product_id: product.id, quantity: 1)
      else
        item.quantity += 1
      end
    end

    def quantity_of (product)
      item = @items.find { |item| item.product_id == product.id }
      item.nil? ? 0 : item.quantity
    end

    def total
      0
    end
  end
end