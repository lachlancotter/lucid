require "lucid/command"

module Shopping
  class AddProductToCart < Lucid::Command
    attribute :product_id
    validate do
      required(:product_id)
      # required(:cart_id)
    end
  end

  class RemoveProductFromCart < Lucid::Command
    attribute :product_id
    validate do
      required(:product_id)
      # required(:cart_id)
    end
  end

  class EmptyCart < Lucid::Command
    validate do
      # required(:cart_id)
    end
  end

  class PlaceOrder < Lucid::Command
    validate do
      # required(:cart_id)
    end
  end
end