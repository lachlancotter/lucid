module Shopping

  describe "Shopping", type: :feature do

    before do
      visit "/"
    end

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
      click_link "Open Cart"
      within ".cart" do
        expect(page).to have_content("Gibson Les Paul")
        expect(page).to have_content("1")
        expect(page).to have_content("$2,499")
      end
      within ".product-details" do
        expect(page).to have_content("Gibson Les Paul")
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

    scenario "review order" do
      click_link "Guitars & Basses"
      click_link "Gibson Les Paul"
      click_button "Add to Cart"
      click_link "Open Cart"
      within ".cart" do
        click_link "Checkout"
      end
      within ".checkout" do
        expect(page).to have_content("Checkout")
        expect(page).to have_content("Gibson Les Paul")
        expect(page).to have_content("1")
        expect(page).to have_content("$2,499")
      end
    end

    scenario "enter shipping address" do
      click_link "Guitars & Basses"
      click_link "Gibson Les Paul"
      click_button "Add to Cart"
      click_link "Open Cart"
      within ".cart" do
        click_link "Checkout"
      end
      within ".checkout" do
        fill_in "Name", with: "John Doe"
        fill_in "Street", with: "123 Main Street"
        fill_in "City", with: "Anytown"
        fill_in "State", with: "CA"
        fill_in "Zip", with: "90210"
        click_button "Continue"
      end
      within ".checkout" do
        expect(page).to have_content("John Doe")
        expect(page).to have_content("123 Main Street")
        expect(page).to have_content("Anytown, CA 90210")
      end
    end

    # scenario "invalid shipping address" do
    #   click_link "Guitars & Basses"
    #   click_link "Gibson Les Paul"
    #   click_button "Add to Cart"
    #   click_link "Open Cart"
    #   within ".cart" do
    #     click_link "Checkout"
    #   end
    #   within ".checkout" do
    #     fill_in "Name", with: "Invalid Test"
    #     fill_in "Street", with: ""
    #     click_button "Continue"
    #     expect(page).to have_content("must be filled")
    #   end
    # end

  end
end