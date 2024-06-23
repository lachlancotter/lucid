module Shopping
  class Session
    class Authenticated < Lucid::Event
      validate do
        required(:email).filled(:string)
      end
    end
  end
end