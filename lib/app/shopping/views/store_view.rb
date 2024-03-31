module Shopping
  class StoreView < Lucid::Component::Base
    # path(:category_slug).maybe(:string)
    # path(:product_id).maybe(:integer)

    path :category_slug, :product_id
    validate do
      optional(:product_id).maybe(:integer)
      optional(:category_slug).maybe(:string)
    end

    visit Product::List, :category_slug
    visit Product::Show, :product_id

    nest :nav, CategoryNavView
    nest :cart_view, CartView

    # ===================================================== #
    #    Data
    # ===================================================== #

    let(:product) { |product_id| Product.find(product_id) rescue nil }
    let(:category) { |category_slug| Category.find_by_slug(category_slug) }
    let(:products) { |category| Product.in_category(category) rescue [] }
    let(:cart) { Session.current.cart }

    # ===================================================== #
    #    View
    # ===================================================== #

    template do |product, products|
      div(style: "display: flex; flex-direction: row; gap: 1em;") {
        emit_view :nav
        emit_template :product_list, products
        emit_template :product_details, product
        emit_view :cart_view

        # emit view(:nav)
        # emit product_list(products)
        # emit product_details(product, cart)
        # emit view(:cart_view)
      }
    end

    template :product_list do |products|
      div(class: "product-list") {
        products.each do |product|
          div { emit show_link(product) }
        end
      }
    end

    template :product_details do |product|
      div(class: "product-details") {
        if product.nil?
          text "No product selected."
        else
          h3 product.name
          p product.description
          p product.price
          emit add_button(product)
        end
      }
    end

    # ===================================================== #
    #    Helpers
    # ===================================================== #

    def show_link (product)
      Product::Show.link(product.name, product_id: product.id)
    end

    def add_button (product)
      Cart::AddProduct.button("Add to Cart",
         product_id: product.id, cart_id: cart.id
      )
    end

  end
end