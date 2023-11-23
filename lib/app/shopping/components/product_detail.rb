module Shopping
  class ProductDetail < Lucid::Component::Base
    config do
      option :product, default: nil
    end

    template do
      h2 { text product[:name] }
      p { text product[:description] }
      p { text product[:price] }
    end
  end
end