require "capybara-screenshot/rspec"

#
# HTML Screenshots.
#
RSpec.configure do |config|
  config.after(type: :feature) do |example|
    if example.exception
      filename = File.join(Capybara.save_path, "screenshot-#{Time.now.strftime('%Y%m%d%H%M%S')}.html")
      page.save_page(filename)
      puts "Saved screenshot to #{filename}"
    end
  end
end
