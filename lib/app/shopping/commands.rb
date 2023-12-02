require "lucid/command"

module Shopping
  class AddProductToCart < Lucid::Command
    attribute :product_id
    attribute :cart_id
    validate do
      required(:product_id).filled(:integer)
      required(:cart_id).filled(:integer)
    end
  end

  class RemoveProductFromCart < Lucid::Command
    attribute :product_id
    attribute :cart_id
    validate do
      required(:product_id).filled(:integer)
      required(:cart_id).filled(:integer)
    end
  end

  class EmptyCart < Lucid::Command
    attribute :cart_id
    validate do
      required(:cart_id).filled(:integer)
    end
  end

  class SetShippingAddress < Lucid::Command
    attribute :cart_id
    attribute :address
    validate do
      required(:cart_id).filled(:integer)
      required(:address).hash do
        required(:name).filled
        required(:street).filled
        required(:city).filled
        required(:state).filled
        required(:zip).filled
      end
    end
  end

  class PlaceOrder < Lucid::Command
    attribute :cart_id
    validate do
      required(:cart_id)
    end
  end
end