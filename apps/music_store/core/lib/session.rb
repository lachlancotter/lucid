module MusicStore
  class Session < Lucid::App::Session
    key :cart_id, Types.string.default { SecureRandom.uuid }
    key :user_email, Types.string.optional.default(nil)
    let(:cart) { |cart_id| Cart.get(cart_id) }
  end
end