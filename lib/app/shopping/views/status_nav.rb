module Shopping
  class StatusNav < Lucid::Component::Base
    let(:username) { |session| session[:user_email] || "Guest" }
    on(Session::Authenticated) { render.replace }

    template do |username|
      div(class: "status-nav") {
        text username
        br
        emit Session::New.link("Login")
        emit Admin::Link.link("Admin")
      }
    end
  end
end