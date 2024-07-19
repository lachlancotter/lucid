module MusicStore
  module Checkout

    # ===================================================== #
    #    Links
    # ===================================================== #

    class Link < Lucid::Link

    end

    # ===================================================== #
    #    Commands
    # ===================================================== #

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

    class PlaceOrder < Lucid::Command
      validate do
        required(:cart_id).filled(:integer)
      end
    end

    # ===================================================== #
    #    Events
    # ===================================================== #

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
end