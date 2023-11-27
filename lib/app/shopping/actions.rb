require "lucid/commandable"

module Shopping
  class Actions
    include Lucid::Commandable

    perform AddProductToCart do |cmd|
      product = Product.find(cmd.product_id)
      Cart.current.add_product(product)
      notify_item_changed(product)
    end

    perform RemoveProductFromCart do |cmd|
      product = Product.find(cmd.product_id)
      Cart.current.remove_product(product)
      notify_item_changed(product)
    end

    perform EmptyCart do |cmd|
      CartEmptied.notify(cart_id: cmd.cart_id)
    end

    perform SetShippingAddress do |cmd|
      Cart.current.shipping_address = cmd.address
      Cart.current.save
    end

    perform PlaceOrder do |cmd|
      OrderPlaced.notify(cart_id: cmd.cart_id)
    end

    def self.notify_item_changed (product)
      CartItemChanged.notify({
         product_id: product.id,
         cart_id:    Cart.current.id,
         quantity:   Cart.current.quantity_of(product)
      })
    end
  end
end