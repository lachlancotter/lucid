module MusicStore
  module Catalogue
    class ProductListView < Lucid::Component::Base
      prop :products, Types.array

      element do |products|
        div(class: "product-list") {
          h2 "Products"
          products.each do |product|
            div {
              p product.name
              link_to show_product(product), product.name
            }
          end
        }
      end

      def show_product(product)
        ShowProduct[product_id: product.id]
      end
    end
  end
end