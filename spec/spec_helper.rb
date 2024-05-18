require "sinatra"
require "rack/test"
require "webdrivers"
require "capybara/rspec"
require "capybara-screenshot/rspec"

require "app/shopping/boot"

ENV["RACK_ENV"]            = "test"
Shopping::App.environment  = :test

# Basic configuration...
Capybara.app               = Shopping::App
Capybara.default_driver    = :rack_test
Capybara.save_path         = "/tmp/capybara"
Capybara.server_errors     = [StandardError]

# JavaScript tests...
Capybara.register_driver :selenium_chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end
Capybara.javascript_driver = :selenium_chrome
Capybara.server            = :webrick

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
