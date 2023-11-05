require "awesome_print"
require "lucid/component"
require "app/shopping/model/product"
require "app/shopping/links"
require "app/shopping/commands"
require "app/shopping/components/category_nav"
require "app/shopping/components/product_detail"
require "app/shopping/components/cart_detail"

module Shopping
  class Base < Lucid::Component
    # /:category_slug/:product_id
    route { path :category_slug, :product_id }

    state do
      attribute :category_slug
      attribute :product_id
    end

    visit ProductList do |link, delta|
      delta.category_slug = link.category_slug
    end

    visit ProductDetails do |link, delta|
      delta.product_id = link.product_id
    end

    # ===================================================== #
    #    Nested
    # ===================================================== #

    # nest :nav, CategoryNav do |config|
    #   config.items = category_links
    # end

    # nest :detail, ProductDetail do |config|
    #   config.product = Product.find(state.product_id)
    # end
    #
    # nest :cart, CartDetail do |config|
    #   config.cart = Cart.current
    # end

    def products
      if state.category_slug.nil?
        []
      else
        category = Category.find_by_slug(state.category_slug)
        raise "Category not found: #{state.category_slug}" if category.nil?
        Product.in_category(category)
      end
    end

    def product
      Product.find(state.product_id)
    end

    # ===================================================== #
    #    Templates
    # ===================================================== #

    template :main do
      head {
        link(rel: "stylesheet", href: "style.css")
      }
      body {
        emit_template :branding
        div(style: "display: flex; flex-direction: row; gap: 1em;") {
          emit_template :category_list
          emit_template :product_list
          emit_template :product_details
          emit_template :cart
        }
      }
    end

    template :branding do
      div(class: "branding") {
        h2 "Branding"
      }
    end

    template :category_list do
      ul {
        Category.all.each do |cat|
          li { emit ProductList.link(cat.name, category_slug: cat.slug) }
        end
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
          text "No product selected. #{state.product_id}"
        else
          h3 product.name
          p product.description
          p product.price
          emit AddProductToCart.button("Add to cart", product_id: product.id)
        end
      }
    end

    template :cart do
      div(class: "cart") {
        text "Cart: "
        # text Cart.current.total
      }
    end

  end
end