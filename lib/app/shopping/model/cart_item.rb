module Shopping
  class CartItem < OpenStruct
    # :product_id, :quantity

    def product_name
      Product.find(product_id).name
    end

    def price
      Product.find(product_id).price * quantity
    end
  end
end