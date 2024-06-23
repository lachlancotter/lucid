module Shopping
  class Cart
    class ItemChanged < Lucid::Event
      validate do
        required(:product_id).filled(:integer)
        required(:cart_id).filled(:string)
        required(:quantity).filled(:integer)
      end
    end

    class ItemAdded < ItemChanged
    end

    class ItemRemoved < ItemChanged
    end

    class Emptied < Lucid::Event
      validate do
        required(:cart_id).filled(:string)
      end
    end
  end
end