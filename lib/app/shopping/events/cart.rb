module Shopping
  class Cart
    class ItemChanged < Lucid::Event
      validate do
        required(:product_id)
        required(:cart_id).filled
        required(:quantity)
      end
    end

    class Emptied < Lucid::Event
      validate do
        required(:cart_id)
      end
    end
  end
end