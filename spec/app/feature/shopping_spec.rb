describe "Shopping", type: :feature do

  scenario "browse guitars" do
    visit "/"
    click_link "Guitars & Basses"
    within ".product-list" do
      expect(page).to have_content("Gibson Les Paul")
    end
  end

  scenario "browse pianos" do
    visit "/"
    click_link "Pianos & Keyboards"
    within ".product-list" do
      expect(page).to have_content("Yamaha C7")
    end
  end

  scenario "view product details" do
    visit "/"
    click_link "Guitars & Basses"
    click_link "Gibson Les Paul"
    within ".product-details" do
      expect(page).to have_content("Iconic electric guitar")
    end
  end

end