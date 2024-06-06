module Shopping
  class Product
    class ShowView < Lucid::Component::Base
      prop :product, Types.Instance(Product).optional
      use :cart, from: :session

      element do |product, cart|
        div(class: "product-details") {
          if product.nil?
            text "No product selected."
          else
            h3 product.name
            p product.description
            p product.price
            button_to add_product(product, cart), "Add to Cart"
          end
        }
      end

      def add_product (product, cart)
        Cart::AddProduct[product_id: product.id, cart_id: cart.id]
      end
    end
  end
end