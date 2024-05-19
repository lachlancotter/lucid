module Shopping
  class StatusNav < Lucid::Component::Base
    let(:username) { |session| session[:user_email] || "Guest" }
    on(Session::Authenticated) { element.replace }

    element do |username|
      div(class: "status-nav") {
        text username
        br
        link_to Session::New, "Login"
        link_to Admin::Link, "Admin"
      }
    end
  end
end