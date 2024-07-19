module MusicStore
  module Checkout
    class Handler < Lucid::Handler
      prop :session, Types.Instance(MusicStore::Session)

      perform SetShippingAddress do |cmd|
        cart                  = session.cart
        cart.shipping_address = cmd.address
        cart.save
        ShippingAddressUpdated.notify(cmd.to_h)
      end

      perform PlaceOrder do |cmd|
        OrderPlaced.notify(cart_id: cmd.cart_id)
      end
    end
  end
end