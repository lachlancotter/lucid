module Shopping
  class Cart
    class TotalView < Lucid::Component::Base
      use :cart, from: :session
      let(:total) { |cart| cart.total }
      on(Cart::ItemChanged) { invalidate(:total) }
      element do |total|
        p "Total: #{Format.currency(total)}"
      end
    end
  end
end