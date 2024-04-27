module Shopping
  class LoginView < Lucid::Component::Base
    param :show, default: "false"
    visit(Session::New) { update(show: "true") }
    on(Session::Authenticated) { update(show: "false") }

    template do |show|
      if on(show)
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

    def on (arg)
      arg == "true"
    end
  end
end