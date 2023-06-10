require "sinatra"
require "capybara/rspec"
require "capybara-screenshot/rspec"
require "rack/test"
require "lucid/demo_app"

Capybara.app = DemoApp
Capybara.default_driver = :rack_test
Capybara.save_path = "/tmp/capybara"