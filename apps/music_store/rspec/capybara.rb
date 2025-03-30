require "capybara/rspec"
require "webdrivers"

ENV["RACK_ENV"] = "test"

# Basic configuration...
Capybara.app             = MusicStore::App
Capybara.app.environment = :test
Capybara.default_driver  = :rack_test
Capybara.server          = :webrick
Capybara.save_path       = "/tmp/capybara"
Capybara.server_errors   = [StandardError]

# JavaScript tests...
Capybara.register_driver :selenium_chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end
Capybara.javascript_driver = :selenium_chrome