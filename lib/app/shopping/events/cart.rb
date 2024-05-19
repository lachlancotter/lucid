module Shopping
  class Cart
    class ItemChanged < Lucid::Event
      validate do
        required(:product_id).filled
        required(:cart_id).filled
        required(:quantity).filled
      end
    end

    class ItemAdded < ItemChanged
    end

    class ItemRemoved < ItemChanged
    end

    class Emptied < Lucid::Event
      validate do
        required(:cart_id)
      end
    end
  end
end