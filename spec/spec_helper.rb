require "sinatra"
require "rack/test"
require "capybara/rspec"
require "capybara-screenshot/rspec"

require "app/shopping/boot"

ENV["RACK_ENV"] = "test"
Shopping::App.environment = :test
Capybara.app = Shopping::App
Capybara.default_driver = :rack_test
Capybara.save_path = "/tmp/capybara"
Capybara.server_errors = [StandardError]

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
