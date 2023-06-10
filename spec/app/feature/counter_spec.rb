describe "LinkCounter app", type: :feature do
  scenario "new counter" do
    visit "/counter"
    expect(page).to have_content("Count: 0")
  end

  scenario "increment counter" do
    visit "/counter"
    click_link "Inc"
    expect(page).to have_content("Count: 1")
  end

  scenario "double increment counter" do
    visit "/counter"
    click_link "Inc"
    click_link "Inc"
    expect(page).to have_content("Count: 2")
  end

  scenario "decrement counter" do
    visit "/counter"
    click_link "Dec"
    expect(page).to have_content("Count: -1")
  end
end