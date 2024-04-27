module Shopping
  class Session
    class Authenticate < Lucid::Command
      attribute :email
      validate do
        required(:email)
      end
    end
  end
end