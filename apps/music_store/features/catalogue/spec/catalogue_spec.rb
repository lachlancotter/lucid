module MusicStore
  describe "Catalogue", type: :feature do

    before { visit "/" }

    scenario "browse guitars" do
      click_link "Guitars & Basses"
      within ".product-list" do
        expect(page).to have_content("Gibson Les Paul")
      end
    end

    scenario "browse pianos" do
      click_link "Pianos & Keyboards"
      within ".product-list" do
        expect(page).to have_content("Yamaha C7")
      end
    end

    scenario "view product details" do
      click_link "Guitars & Basses"
      click_link "Gibson Les Paul"
      within ".product-details" do
        expect(page).to have_content("Iconic electric guitar")
      end
    end

  end
end