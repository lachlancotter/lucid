describe "MultiCounter app", type: :feature, skip: true do
  before do
    MultiCounter::Store.reset!
  end

  scenario "no counters" do
    visit "/multi_counter"
    expect(page).to have_content("No Counters")
  end

  scenario "new counter" do
    visit "/multi_counter"
    fill_in "Name", with: "Foo"
    click_button "Create Counter"
    expect(page).to have_content("Foo Count: 0")
  end

  scenario "increment counter" do
    MultiCounter::Store.create("Foo")
    visit "/multi_counter"
    puts page.body
    click_button "Inc"
    expect(page).to have_content("Foo Count: 1")
  end

  scenario "double increment counter" do
    MultiCounter::Store.create("Foo")
    visit "/multi_counter"
    click_button "Inc"
    click_button "Inc"
    expect(page).to have_content("Foo Count: 2")
  end

  scenario "decrement counter" do
    visit "/multi_counter"
    click_button "Dec"
    expect(page).to have_content("Count: -1")
  end
end