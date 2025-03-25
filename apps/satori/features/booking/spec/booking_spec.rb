module Satori
  describe "Booking", type: :feature do
    before do
      visit "/"
    end

    scenario "view calendar" do
      expect(page).to have_css(".booking-calendar")
    end
  end
end