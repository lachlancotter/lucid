module MusicStore
  module ShoppingCart
    class Handler < Lucid::Handler
      prop :session, Types.Instance(MusicStore::Session)

      perform Empty do |cmd|
        Emptied.notify(cart_id: cmd.cart_id)
      end

      perform AddProduct do |cmd|
        product = Product.find(cmd.product_id)
        cart    = session.cart
        cart.add_product(product)
        ItemAdded.notify({
           product_id: product.id,
           cart_id:    cart.id,
           quantity:   cart.quantity_of(product)
        })
      end

      perform RemoveProduct do |cmd|
        product = Product.find(cmd.product_id)
        cart    = session.cart
        cart.remove_product(product)
        ItemRemoved.notify({
           product_id: product.id,
           cart_id:    cart.id,
           quantity:   cart.quantity_of(product)
        })
      end
    end
  end
end