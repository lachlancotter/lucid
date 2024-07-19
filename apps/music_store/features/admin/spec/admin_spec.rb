module MusicStore
  describe "Admin", type: :feature do
    before { visit "/" }

    scenario "not authorized" do
      click_link "Admin"
      expect(page).to have_content("not authorized")
    end

    scenario "authorized" do
      click_link "Login"
      within ".login" do
        fill_in "Email", with: "test.user@lucid.dev"
        click_button "Login"
      end
      click_link "Admin"
      expect(page).to have_content("Admin area")
    end
  end
end