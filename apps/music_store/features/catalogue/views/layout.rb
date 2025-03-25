module MusicStore
  module Catalogue
    class Layout < Lucid::Component::Base
      route "/:category_slug/:product_id"
      param :category_slug, Types.string.optional.default(nil)
      param :product_id, Types.integer.optional.default(nil)
      
      visit ListProducts, :category_slug
      visit ShowProduct, :product_id

      # ===================================================== #
      #    Data
      # ===================================================== #

      let(:product) { |product_id| Product.find(product_id) rescue nil }
      let(:category) { |category_slug| Category.find_by_slug(category_slug) }
      let(:products) { |category| Product.in_category(category) rescue [] }

      # ===================================================== #
      #    Subviews
      # ===================================================== #

      nest(:nav) { CategoryNavView }
      nest(:product_list) { |products| ProductListView[products: products] }
      nest(:product_details) { |product| ProductView[product: product] }
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