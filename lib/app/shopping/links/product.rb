module Shopping
  class Product
    class Link < Lucid::Link

    end

    class List < Link
      validate do
        required(:category_slug).filled(:string)
      end
    end

    class Show < Link
      validate do
        required(:product_id).filled(:integer)
      end
    end
  end
end