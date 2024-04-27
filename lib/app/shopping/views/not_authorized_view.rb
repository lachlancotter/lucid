module Shopping
  class NotAuthorizedView < Lucid::Component::Base
    template do
      div(class: "denied") do
        h1 "Access Denied"
        p "You are not authorized to view this page."
      end
    end
  end
end