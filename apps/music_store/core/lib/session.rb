module MusicStore
  class Session < Lucid::Session
    attribute :cart_id, Types.string.default { SecureRandom.uuid }
    attribute :user_email, Types.string.optional.default(nil)
    let(:cart) { |cart_id| Cart.get(cart_id) }
  end
end