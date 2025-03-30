module MusicStore
  module Catalogue
    class CategoryNav < Lucid::Component::Base
      element do
        ul {
          Category.all.each do |cat|
            li { link_to product_list(cat), cat.name }
          end
        }
      end

      def product_list (category)
        ListProducts.new(category_slug: category.slug)
      end
    end
  end
end