module MusicStore
  module Authentication
    class LoginPanel < Lucid::Component::Base
      param :show, Types.bool.default(false)

      to ShowLogin, show: true
      on(Authenticated) { update(show: false) }
      echo :credentials, Authenticate

      element do |show, credentials|
        if show
          div(class: "login") {
            div(class: "dialog") {
              h2 "Login"
              form_for(credentials) { |f|
                f.label(:email, "Email")
                f.text(:email, placeholder: "Email")
                f.submit("Login")
              }
            }
          }
        end
      end

    end
  end
end