module Shopping
  class StatusNav < Lucid::Component::Base
    use :user_email, from: :session
    let(:username) { |user_email| user_email || "Guest" }

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