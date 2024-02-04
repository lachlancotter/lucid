require "lucid/event"

module Shopping
  module Events
    # Zeitwerk expects to find this constant here.
  end

  class CartItemChanged < Lucid::Event
    validate do
      required(:product_id)
      required(:cart_id).filled
      required(:quantity)
    end
  end

  class CartEmptied < Lucid::Event
    validate do
      required(:cart_id)
    end
  end

  class ShippingAddressUpdated < Lucid::Event
    validate do
      required(:cart_id)
      required(:address).hash do
        required(:name).filled
        required(:street).filled
        required(:city).filled
        required(:state).filled
        required(:zip).filled
      end
    end
  end

  class OrderPlaced < Lucid::Event
    validate do
      required(:cart_id)
    end
  end
end