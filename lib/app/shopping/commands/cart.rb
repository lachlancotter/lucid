module Shopping
  class Cart
    class AddProduct < Lucid::Command
      validate do
        required(:product_id).filled(:integer)
        required(:cart_id).filled(:string)
      end
    end

    class RemoveProduct < Lucid::Command
      validate do
        required(:product_id).filled(:integer)
        required(:cart_id).filled(:string)
      end
    end

    class Empty < Lucid::Command
      validate do
        required(:cart_id).filled(:string)
      end
    end
  end
end