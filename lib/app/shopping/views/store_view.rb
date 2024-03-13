module Shopping
  class StoreView < Lucid::Component::Base
    path :category_slug, :product_id
    visit Product::List, :category_slug
    visit Product::Show, :product_id

    nest :nav, CategoryNavView
    nest :cart_view, CartView

    # ===================================================== #
    #    Data
    # ===================================================== #

    def cart
      Session.current.cart
    end

    def products
      if state[:category_slug].nil?
        []
      else
        category = Category.find_by_slug(state[:category_slug])
        raise "Category not found: #{state[:category_slug]}" if category.nil?
        Product.in_category(category)
      end
    end

    def product
      Product.find(state[:product_id].to_i)
    end

    # ===================================================== #
    #    View
    # ===================================================== #

    template do
      div(style: "display: flex; flex-direction: row; gap: 1em;") {
        emit_view :nav
        emit_template :product_list
        emit_template :product_details
        emit_view :cart_view
      }
    end

    template :product_list do
      div(class: "product-list") {
        products.each do |product|
          div {
            emit Product::Show.link(product.name, product_id: product.id)
          }
        end
      }
    end

    template :product_details do
      div(class: "product-details") {
        if product.nil?
          text "No product selected. #{state[:product_id]}"
        else
          h3 product.name
          p product.description
          p product.price
          emit Cart::AddProduct.button(
             "Add to Cart", product_id: product.id, cart_id: cart.id
          )
        end
      }
    end

  end
end