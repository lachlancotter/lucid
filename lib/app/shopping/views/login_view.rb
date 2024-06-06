module Shopping
  class LoginView < Lucid::Component::Base
    param :show, Types.bool.default(false)
    visit Session::New, show: true
    on(Session::Authenticated) { update(show: false) }

    element do |show|
      if show
        div(class: "login") {
          div(class: "dialog") {
            h2 "Login"
            form_for Session::Authenticate do |f|
              emit f.label(:email, "Email")
              emit f.text(:email, placeholder: "Email")
              emit f.submit("Login")
            end
          }
        }
      end
    end
  end
end