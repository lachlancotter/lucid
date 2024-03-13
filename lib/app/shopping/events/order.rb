module Shopping
  module Order
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

    class Placed < Lucid::Event
      validate do
        required(:cart_id)
      end
    end
  end
end