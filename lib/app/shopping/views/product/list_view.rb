module Shopping
  class Product
    class ListView < Lucid::Component::Base
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
        Product::Show[product_id: product.id]
      end
    end
  end
end