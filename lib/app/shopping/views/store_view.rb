module Shopping
  class StoreView < Lucid::Component::Base
    # map "/:category_slug/:product_id" do |category_slug, product_id|
    #   category_slug.type(:string).enum(Category.slugs)
    #   product_id.type(:integer)
    # end

    path :category_slug, Types.string.optional.default(nil)
    path :product_id, Types.integer.optional.default(nil)

    visit Product::List, :category_slug
    visit Product::Show, :product_id

    # ===================================================== #
    #    Data
    # ===================================================== #

    let(:product) { |product_id| Product.find(product_id.to_i) rescue nil }
    let(:category) { |category_slug| Category.find_by_slug(category_slug) }
    let(:products) { |category| Product.in_category(category) rescue [] }

    # ===================================================== #
    #    Subviews
    # ===================================================== #

    nest(:nav) { CategoryNavView }
    nest(:product_list) { |products| Product::ListView[products: products] }
    nest(:product_details) { |product| Product::ShowView[product: product] }
    nest(:cart_view) { Cart::BaseView }

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