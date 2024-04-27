module Shopping
  class Session
    class Authenticated < Lucid::Event
      validate do
        required(:email).filled(:str?)
      end
    end
  end
end