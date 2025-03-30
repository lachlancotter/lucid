module MusicStore
  module Catalogue
    class Layout < Lucid::Component::Base
      route "/:category_slug/:product_id"
      param :category_slug, Types.string.optional.default(nil)
      param :product_id, Types.integer.optional.default(nil)
      
      to ListProducts, :category_slug
      to ShowProduct, :product_id

      # ===================================================== #
      #    Data
      # ===================================================== #

      let(:product) { |product_id| Product.find(product_id) rescue nil }
      let(:category) { |category_slug| Category.find_by_slug(category_slug) }
      let(:products) { |category| Product.in_category(category) rescue [] }

      # ===================================================== #
      #    Subviews
      # ===================================================== #

      nest(:nav) { CategoryNav }
      nest(:product_list) { |products| ProductListing[products: products] }
      nest(:product_details) { |product| ProductDetails[product: product] }
      nest(:cart_view) { ShoppingCart::CartView }

      # ===================================================== #
      #    Template
      # ===================================================== #

      element do
        div(class: "store") {
          subview :nav
          subview :product_list
          subview :product_details
          subview :cart_view
        }
      end
    end
  end
end