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
    attribute :address, default: {}
    validate do
      required(:cart_id).filled(:integer)
      required(:address).hash do
        required(:name).filled(:string)
        required(:street).filled(:string)
        required(:city).filled(:string)
        required(:state).filled(:string)
        required(:zip).filled(:string)
      end
    end
  end

  class PlaceOrder < Lucid::Command
    attribute :cart_id
    validate do
      required(:cart_id).filled(:integer)
    end
  end
end