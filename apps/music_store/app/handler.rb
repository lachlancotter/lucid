module MusicStore
  class Handler < Lucid::Handler
    recruit Authentication::Handler
    recruit Catalogue::Handler
    recruit ShoppingCart::Handler
    recruit Checkout::Handler
  end
end