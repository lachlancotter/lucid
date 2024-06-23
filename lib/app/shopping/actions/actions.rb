module Shopping
  class Actions
    include Lucid::Commandable

    def initialize (session)
      @session = session
    end

    perform Session::Authenticate do |cmd|
      @session.put(user_email: cmd.email)
      Session::Authenticated.notify(email: cmd.email)
    end

    perform Cart::AddProduct do |cmd|
      product = Product.find(cmd.product_id)
      cart    = @session.cart
      cart.add_product(product)
      Cart::ItemAdded.notify({
         product_id: product.id,
         cart_id:    cart.id,
         quantity:   cart.quantity_of(product)
      })
    end

    perform Cart::RemoveProduct do |cmd|
      product = Product.find(cmd.product_id)
      cart    = @session.cart
      cart.remove_product(product)
      Cart::ItemRemoved.notify({
         product_id: product.id,
         cart_id:    cart.id,
         quantity:   cart.quantity_of(product)
      })
    end

    perform Cart::Empty do |cmd|
      Cart::Emptied.notify(cart_id: cmd.cart_id)
    end

    perform Order::SetShippingAddress do |cmd|
      cart                  = @session.cart
      cart.shipping_address = cmd.address
      cart.save
      Order::ShippingAddressUpdated.notify(cmd.to_h)
    end

    perform Order::Place do |cmd|
      Order::Placed.notify(cart_id: cmd.cart_id)
    end

  end
end