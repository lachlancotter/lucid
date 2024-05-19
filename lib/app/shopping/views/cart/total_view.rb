module Shopping
  class Cart
    class TotalView < Lucid::Component::Base
      prop :cart
      let(:total) { |cart| cart.total }
      on(Cart::ItemChanged) { invalidate(:total) }
      element { |total| p { Format.currency(total) } }
    end
  end
end