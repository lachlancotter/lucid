module Shopping
  class Actions
    include Lucid::Commandable

    perform Cart::AddProduct do |cmd|
      product = Product.find(cmd.product_id)
      cart    = Cart.get(cmd.cart_id)
      cart.add_product(product)
      notify_item_changed(cart, product)
    end

    perform Cart::RemoveProduct do |cmd|
      product = Product.find(cmd.product_id)
      cart    = Cart.get(cmd.cart_id)
      cart.remove_product(product)
      notify_item_changed(cart, product)
    end

    perform Cart::Empty do |cmd|
      Cart::Emptied.notify(cart_id: cmd.cart_id)
    end

    perform Order::SetShippingAddress do |cmd|
      cart                  = Cart.get(cmd.cart_id)
      cart.shipping_address = cmd.address
      cart.save
      Order::ShippingAddressUpdated.notify(cmd.params)
    end

    perform Order::Place do |cmd|
      Order::Placed.notify(cart_id: cmd.cart_id)
    end

    def self.notify_item_changed (cart, product)
      Cart::ItemChanged.notify({
         product_id: product.id,
         cart_id:    cart.id,
         quantity:   cart.quantity_of(product)
      })
    end
  end
end