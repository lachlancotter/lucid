require "capybara/rspec"
require "webdrivers"

# Basic configuration...
Capybara.app               = Satori::Server
Capybara.default_driver    = :rack_test
Capybara.server            = :webrick
Capybara.save_path         = "/tmp/capybara"
Capybara.server_errors     = [StandardError]

# JavaScript tests...
Capybara.register_driver :selenium_chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end
Capybara.javascript_driver = :selenium_chrome