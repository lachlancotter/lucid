module Shopping
  class AdminView < Lucid::Component::Base
    use :user_email, from: :session

    guard do |user_email|
      case user_email
      when "test.user@lucid.dev"
        Lucid::Permit
      else
        Lucid::Deny
      end
    end

    element do |user_email|
      div(class: "admin") do
        h1 "Admin area"
        p "You are logged in as #{user_email}"
      end
    end
  end
end