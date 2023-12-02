module Shopping
  class ProductDetail < Lucid::Component::Base
    setting :product, default: nil

    template do
      h2 { text product[:name] }
      p { text product[:description] }
      p { text product[:price] }
    end
  end
end