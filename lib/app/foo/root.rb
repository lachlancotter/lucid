describe "Send an Email" do
  scenario "happy path", drive: AppRoot do |app|
    nav_to app.messages
    within app.main do |messages|
      nav_to messages.compose
      fill_in messages.create, with: {
         to:      "",
         subject: "",
         body:    ""
      }
      submit messages.create
    end

    within app do
      nav_to messages > compose
      within create_message.form do
        fill_in({
           to:      "",
           subject: "",
           body:    ""
        })
        submit
      end
      expect_content "Message sent"
    end

    # expect(app.main).to have_content("Message sent")
    app.status.expect_content("Message sent")

    # links.messages.visit
    # divs.messages.drive do
    #   links.new_email.visit
    #   new_email.form.submit({
    #      to:      "",
    #      subject: "",
    #      body:    ""
    #   })
  end
end

class AppRoot < Lucid::View
  path :page

  state do
    attr :page, Types::Strict::String, default: "home"
  end

  href :home, { page: "home" }
  href :about, { page: "about" }
  href :contacts, { page: "contacts" }

  div :nav_bar, class: NavBar do |props|
    props.links = links
  end

  div :content, class: Container do |props|
    props.content_class = class_mapping.fetch(page)
  end

  def render
    <<~HTML
      <div>
        #{nav_bar}
        #{content}
      </div>
    HTML
  end

  private

  def self.class_mapping
    {
       home:     Home,
       about:    About,
       contacts: Contacts
    }
  end
end

AppRoot.mount do |config|

end