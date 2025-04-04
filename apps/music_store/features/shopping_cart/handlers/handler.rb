module MusicStore
  module ShoppingCart
    class Handler < Lucid::Handler
      perform Empty do |cmd|
        cart = session.cart
        cart.empty
        publish Emptied.new(cart_id: cmd.cart_id)
      end

      perform AddProduct do |cmd|
        product = Product.find(cmd.product_id)
        cart    = session.cart
        cart.add_product(product)
        publish ItemAdded.new(event_data(product, cart))
      end

      perform RemoveProduct do |cmd|
        product = Product.find(cmd.product_id)
        cart    = session.cart
        cart.remove_product(product)
        publish ItemRemoved.new(event_data(product, cart))
      end
      
      def event_data (product, cart)
        {
           product_id: product.id,
           cart_id:    cart.id,
           quantity:   cart.quantity_of(product)
        }
      end
    end
  end
end