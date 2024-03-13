module Shopping
  class Product
    class Link < Lucid::Link

    end

    class List < Link
      attribute :category_slug
      validate do
        required(:category_slug)
      end
    end

    class Show < Link
      attribute :product_id
      validate do
        required(:product_id)
      end
    end
  end
end