require "lucid/link"

module Shopping
  module Links
    # Zeitwerk expects to find this constant here.
  end

  class ProductList < Lucid::Link
    attribute :category_slug
    validate do
      required(:category_slug)
    end
  end

  class ProductDetails < Lucid::Link
    attribute :product_id
    validate do
      required(:product_id)
    end
  end
end