module Shopping
  class Product
    class ShowView < Lucid::Component::Base
      prop :product
      use :cart

      template do |product, cart|
        div(class: "product-details") {
          if product.nil?
            text "No product selected."
          else
            h3 product.name
            p product.description
            p product.price
            emit Cart::AddProduct.button("Add to Cart",
               product_id: product.id, cart_id: cart.id
            )
          end
        }
      end
    end
  end
end