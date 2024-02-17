require "awesome_print"
require "lucid/component/base"
require "app/shopping/model/product"
require "app/shopping/links"
require "app/shopping/commands"
require "app/shopping/components/category_nav"
require "app/shopping/components/product_detail"
require "app/shopping/components/cart_detail"
require "app/shopping/session"

module Shopping
  class StoreComponent < Lucid::Component::Base
    path :category_slug, :product_id

    visit(ProductList) { |link| state.update(category_slug: link.category_slug) }
    visit(ProductDetails) do |link|
      state.update(product_id: link.product_id)
    end

    nest :nav, CategoryNav
    nest :cart_view, CartDetail

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
            emit ProductDetails.link(product.name, product_id: product.id)
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
          emit AddProductToCart.button(
             "Add to Cart", product_id: product.id, cart_id: cart.id
          )
        end
      }
    end

  end
end