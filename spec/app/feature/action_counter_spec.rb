describe "ActionCounter app", type: :feature do
  before do
    CounterStore.new.reset!
  end
  scenario "new counter" do
    visit "/action_counter"
    expect(page).to have_content("Count: 0")
  end

  scenario "increment counter" do
    visit "/action_counter"
    click_button "Inc"
    expect(page).to have_content("Count: 1")
  end

  scenario "double increment counter" do
    visit "/action_counter"
    click_button "Inc"
    click_button "Inc"
    expect(page).to have_content("Count: 2")
  end

  scenario "decrement counter" do
    visit "/action_counter"
    click_button "Dec"
    expect(page).to have_content("Count: -1")
  end
end