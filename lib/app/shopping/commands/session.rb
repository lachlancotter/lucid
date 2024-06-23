module Shopping
  class Session
    class Authenticate < Lucid::Command
      validate do
        required(:email).filled(:string)
      end
    end
  end
end