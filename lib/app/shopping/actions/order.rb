module Shopping
  module Order
    class Actions < Lucid::Handler
      prop :session, Types.Instance(Shopping::Session)

      perform SetShippingAddress do |cmd|
        cart                  = session.cart
        cart.shipping_address = cmd.address
        cart.save
        ShippingAddressUpdated.notify(cmd.to_h)
      end

      perform Place do |cmd|
        Order::Placed.notify(cart_id: cmd.cart_id)
      end
    end
  end
end