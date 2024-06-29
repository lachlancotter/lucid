module Shopping
  class Session
    class Actions < Lucid::Handler
      prop :session, Types.Instance(Shopping::Session)

      perform Authenticate do |cmd|
        session.put(user_email: cmd.email)
        Authenticated.notify(email: cmd.email)
      end
    end
  end
end