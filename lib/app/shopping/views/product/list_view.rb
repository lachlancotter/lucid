module Shopping
  class Product
    class ListView < Lucid::Component::Base
      prop :products

      template do |products|
        div(class: "product-list") {
          products.each do |product|
            div { emit show_link(product) }
          end
        }
      end

      def show_link (product)
        Product::Show.link(product.name, product_id: product.id)
      end

    end
  end
end