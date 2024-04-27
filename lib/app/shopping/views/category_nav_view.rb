module Shopping
  class CategoryNavView < Lucid::Component::Base
    template do
      ul {
        Category.all.each do |cat|
          li {
            link_to product_list(cat), cat.name
          }
        end
      }
    end

    def product_list (category)
      Product::List[category_slug: category.slug]
    end
  end
end