module Shopping
  class ProductView < Lucid::Component::Base
    prop :product, default: nil

    template do
      h2 { text product[:name] }
      p { text product[:description] }
      p { text product[:price] }
    end
  end
end