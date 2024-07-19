module MusicStore
  module ShoppingCart
    class CartTotalView < Lucid::Component::Base
      use :cart, from: :session
      let(:total) { |cart| cart.total }
      on(ItemChanged) { invalidate(:total) }
      element do |total|
        p "Total: #{Format.currency(total)}"
      end
    end
  end
end