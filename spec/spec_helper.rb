require "sinatra"
require "capybara/rspec"
require "capybara-screenshot/rspec"
require "rack/test"
require_relative "../server"

Capybara.app = LucidTest
Capybara.default_driver = :rack_test
Capybara.save_path = "/tmp/capybara"