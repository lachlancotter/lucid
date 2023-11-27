require "app/shopping/model/cart"

describe "Shopping", type: :feature do

  before do
    Shopping::Cart.current.empty
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
      expect(page).to have_content("1")
      expect(page).to have_content("$2,499")
    end
  end

  scenario "increment product quantity" do
    click_link "Guitars & Basses"
    click_link "Gibson Les Paul"
    click_button "Add to Cart"
    within ".cart" do
      click_button "+"
      click_button "+"
      expect(page).to have_content("3")
      expect(page).to have_content("$7,497")
    end
  end

  scenario "decrement product quantity" do
    click_link "Guitars & Basses"
    click_link "Gibson Les Paul"
    click_button "Add to Cart"
    within ".cart" do
      click_button "+"
      click_button "-"
      expect(page).to have_content("1")
      expect(page).to have_content("$2,499")
    end
  end

end