module Shopping
  class LoginView < Lucid::Component::Base
    param :show, Types.bool.default(false)
    visit Session::New, show: true
    on(Session::Authenticated) { update(show: false) }
    echo(Session::Authenticate, as: :credentials) { { email: "" } }

    element do |show, credentials|
      if show
        div(class: "login") {
          div(class: "dialog") {
            h2 "Login"
            form_for(credentials) { |f|
              emit f.label(:email, "Email")
              emit f.text(:email, placeholder: "Email")
              emit f.submit("Login")
            }
          }
        }
      end
    end

  end
end