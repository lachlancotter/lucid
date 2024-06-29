module Shopping
  class Actions < Lucid::Handler
    recruit Session::Actions
    recruit Cart::Actions
    recruit Order::Actions
  end
end