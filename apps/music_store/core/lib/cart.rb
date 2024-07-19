module MusicStore
  class Cart
    class InvalidID < ArgumentError
      def initialize (id)
        super("Invalid cart ID: #{id}")
      end
    end

    def self.reset
      @carts = {}
    end

    def self.get (id = uuid)
      carts[id] ||= Match.on(id) do
        type(String) { Cart.new(id) }
        default { Cart.new(uuid) }
      end
    end

    def self.carts
      @carts ||= {}
    end

    def self.uuid
      SecureRandom.uuid
    end

    def initialize (id)
      @items            = []
      @id               = id
      @shipping_address = nil
    end

    attr_reader :items, :id
    attr_accessor :shipping_address

    def save
      # do nothing
    end

    def add_product (product)
      item = @items.find { |item| item.product_id == product.id }
      if item.nil?
        @items << CartItem.new(product_id: product.id, quantity: 1)
      else
        item.quantity += 1
      end
    end

    def remove_product (product)
      item = @items.find { |item| item.product_id == product.id }
      if item.nil?
        # do nothing
      elsif item.quantity == 1
        @items.delete(item)
      else
        item.quantity -= 1
      end
    end

    def empty
      @items = []
    end

    def find (product_id:)
      @items.find { |item| item.product_id == product_id }
    end

    def quantity_of (product)
      item = @items.find { |item| item.product_id == product.id }
      item.nil? ? 0 : item.quantity
    end

    def item_count
      @items.reduce(0) { |sum, item| sum + item.quantity }
    end

    def total
      @items.reduce(0) do |sum, item|
        sum + (item.quantity * Product.find(item.product_id).price)
      end
    end
  end
end