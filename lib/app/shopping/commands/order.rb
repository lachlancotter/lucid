module Shopping
  module Order
    class SetShippingAddress < Lucid::Command
      validate do
        required(:cart_id).filled(:string)
        required(:address).hash do
          required(:name).filled(:string)
          required(:street).filled(:string)
          required(:city).filled(:string)
          required(:state).filled(:string)
          required(:zip).filled(:string)
        end
      end
    end

    class Place < Lucid::Command
      validate do
        required(:cart_id).filled(:integer)
      end
    end
  end
end