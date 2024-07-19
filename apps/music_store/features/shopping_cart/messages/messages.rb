module MusicStore
  module ShoppingCart

    # ===================================================== #
    #    Links
    # ===================================================== #

    class Open < Lucid::Link

    end

    class Close < Lucid::Link

    end

    # ===================================================== #
    #    Commands
    # ===================================================== #

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

    # ===================================================== #
    #    Events
    # ===================================================== #

    class ItemChanged < Lucid::Event
      validate do
        required(:product_id).filled(:integer)
        required(:cart_id).filled(:string)
        required(:quantity).filled(:integer)
      end
    end

    class ItemAdded < ItemChanged
    end

    class ItemRemoved < ItemChanged
    end

    class Emptied < Lucid::Event
      validate do
        required(:cart_id).filled(:string)
      end
    end

  end
end