module MusicStore
  module Authentication
    class Handler < Lucid::Handler
      perform Authenticate do |cmd|
        session.put(user_email: cmd.email)
        publish Authenticated.new(email: cmd.email)
      end
    end
  end
end