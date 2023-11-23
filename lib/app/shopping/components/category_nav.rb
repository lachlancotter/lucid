require "app/shopping/model/category"

module Shopping
  class CategoryNav < Lucid::Component::Base
    # config do
    #   option :items, Category.all
    #   validate do
    #     required(:items).filled.array
    #   end
    # end

    def category_link (cat)
      ProductList.link(cat.name, category_slug: cat.slug)
    end

    template do
      ul {
        Category.all.each do |cat|
          li {
            emit category_link(cat)
          }
        end
      }
    end
  end
end