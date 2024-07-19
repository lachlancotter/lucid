module MusicStore
  describe "Sessions", type: :feature do
    before { visit "/" }

    scenario "guest" do
      within ".header" do
        expect(page).to have_content("Guest")
      end
    end

    scenario "login" do
      within ".header" do
        click_link "Login"
      end
      within ".login" do
        fill_in "Email", with: "test.user@lucid.dev"
        click_button "Login"
      end
      within ".header" do
        expect(page).to have_content("test.user@lucid.dev")
      end
    end

    scenario "logout" do

    end

  end
end