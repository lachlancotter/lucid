module MusicStore
  describe "Shopping Cart", type: :feature do

    before { Cart.reset }
    before { visit "/" }

    scenario "add product to cart" do
      click_link "Guitars & Basses"
      click_link "Gibson Les Paul"
      click_button "Add to Cart"
      click_link "Open Cart"
      within ".cart" do
        expect(page).to have_content("Gibson Les Paul")
        expect(page).to have_content("1")
        expect(page).to have_content("$2,499")
      end
    end

    scenario "add multiple products to cart" do
      click_link "Open Cart"
      click_link "Guitars & Basses"
      click_link "Gibson Les Paul"
      click_button "Add to Cart"
      click_link "Wind Instruments"
      click_link "Alto Saxophone"
      click_button "Add to Cart"
      within ".cart" do
        expect(page).to have_content("Gibson Les Paul")
        expect(page).to have_content("1")
        expect(page).to have_content("$2,499")
        expect(page).to have_content("Alto Saxophone")
        expect(page).to have_content("1")
        expect(page).to have_content("$899")
      end
    end

    scenario "increment product quantity" do
      click_link "Guitars & Basses"
      click_link "Gibson Les Paul"
      click_button "Add to Cart"
      click_link "Open Cart"
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
      click_link "Open Cart"
      within ".cart" do
        click_button "+"
        click_button "-"
        expect(page).to have_content("1")
        expect(page).to have_content("$2,499")
      end
    end

    scenario "remove product from cart" do
      click_link "Guitars & Basses"
      click_link "Gibson Les Paul"
      click_button "Add to Cart"
      click_link "Open Cart"
      within ".cart" do
        click_button "-"
        expect(page).not_to have_content("Gibson Les Paul")
        expect(page).to have_content("$0")
      end
    end
  end
end