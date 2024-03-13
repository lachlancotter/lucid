module Shopping
  class CategoryNavView < Lucid::Component::Base
    # config do
    #   option :items, Category.all
    #   validate do
    #     required(:items).filled.array
    #   end
    # end

    def category_link (cat)
      Store::ListProducts.link(cat.name, category_slug: cat.slug)
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