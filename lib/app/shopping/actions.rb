module Shopping
  class Actions
    include Handler

    perform AddProductToCart do |command|
      cart    = Cart.current
      product = Product.find(command.product_id)
      item    = cart.add(product)
      CartItemChanged.notify(cart_item: item)
    end

    perform RemoveProductFromCart do |command|
      cart = Cart.current
      item = cart.remove(command.product_id)
      CartItemChanged.notify(cart_item: item)
    end

    perform EmptyCart do |command|
      CartEmptied.notify(cart_id: command.cart_id)
    end

    perform PlaceOrder do |command|
      OrderPlaced.notify(cart_id: command.cart_id)
    end
  end
end