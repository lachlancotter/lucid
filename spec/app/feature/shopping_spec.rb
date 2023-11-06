describe "Shopping", type: :feature do

  before do
    visit "/"
  end

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

  scenario "add product to cart" do
    click_link "Guitars & Basses"
    click_link "Gibson Les Paul"
    click_button "Add to Cart"
    within ".cart" do
      expect(page).to have_content("Gibson Les Paul")
    end
  end

end