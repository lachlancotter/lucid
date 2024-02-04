require "lucid/commandable"

module Shopping
  class Actions
    include Lucid::Commandable

    perform AddProductToCart do |cmd|
      product = Product.find(cmd.product_id)
      cart    = Cart.get(cmd.cart_id)
      cart.add_product(product)
      notify_item_changed(cart, product)
    end

    perform RemoveProductFromCart do |cmd|
      product = Product.find(cmd.product_id)
      cart    = Cart.get(cmd.cart_id)
      cart.remove_product(product)
      notify_item_changed(cart, product)
    end

    perform EmptyCart do |cmd|
      CartEmptied.notify(cart_id: cmd.cart_id)
    end

    perform SetShippingAddress do |cmd|
      cart                  = Cart.get(cmd.cart_id)
      cart.shipping_address = cmd.address
      cart.save
      ShippingAddressUpdated.notify(cmd.params)
    end

    perform PlaceOrder do |cmd|
      OrderPlaced.notify(cart_id: cmd.cart_id)
    end

    def self.notify_item_changed (cart, product)
      CartItemChanged.notify({
         product_id: product.id,
         cart_id:    cart.id,
         quantity:   cart.quantity_of(product)
      })
    end
  end
end