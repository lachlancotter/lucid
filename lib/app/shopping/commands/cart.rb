module Shopping
  class Cart
    class AddProduct < Lucid::Command
      attribute :cart_id
      attribute :product_id
      validate do
        required(:product_id).filled(:integer)
        required(:cart_id).filled(:integer)
      end
    end

    class RemoveProduct < Lucid::Command
      attribute :product_id
      attribute :cart_id
      validate do
        required(:product_id).filled(:integer)
        required(:cart_id).filled(:integer)
      end
    end

    class Empty < Lucid::Command
      attribute :cart_id
      validate do
        required(:cart_id).filled(:integer)
      end
    end
  end
end