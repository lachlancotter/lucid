module Shopping
  module Order
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

    class Place < Lucid::Command
      attribute :cart_id
      validate do
        required(:cart_id).filled(:integer)
      end
    end
  end
end