module MusicStore
  module Catalogue

    # ===================================================== #
    #    Links
    # ===================================================== #

    class Link < Lucid::Link

    end

    class ListProducts < Link
      validate do
        required(:category_slug).filled(:string)
      end
    end

    class ShowProduct < Link
      validate do
        required(:product_id).filled(:integer)
      end
    end

  end
end