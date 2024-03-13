module Shopping
  module Store
    class Link < Lucid::Link

    end

    class ListProducts < Link
      attribute :category_slug
      validate do
        required(:category_slug)
      end
    end

    class ShowProduct < Link
      attribute :product_id
      validate do
        required(:product_id)
      end
    end
  end
end