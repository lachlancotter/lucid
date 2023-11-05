require "app/shopping/model/category"

module Shopping
  class CategoryNav < Lucid::Component
    config do
      option :items, Category.all
      validate do
        required(:items).filled.array
      end
    end

    def category_link (cat)
      ProductList.link(cat[:name], category_slug: cat[:slug])
    end

    template :main do
      div(class: "nav") {
        h2 "Categories"
        ul {
          items.each do |cat|
            li {
              emit category_link
            }
          end
        }
      }
    end
  end
end