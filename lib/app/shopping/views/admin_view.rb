module Shopping
  class AdminView < Lucid::Component::Base
    use :user_email, from: :session

    guard do |user_email|
      Match.on(user_email) do
        value("test.user@lucid.dev") { Lucid::Permit }
        default { Lucid::Deny }
      end
    end

    template do |user_email|
      div(class: "admin") do
        h1 "Admin area"
        p "You are logged in as #{user_email}"
      end
    end
  end
end