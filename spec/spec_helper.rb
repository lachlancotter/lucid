require_relative "../lib/lucid.rb"

begin
  require "lucid/rspec"
rescue LoadError
  # The framework gem no longer ships RSpec helpers. Consumer apps can add
  # the companion lucid-rspec gem when they need them.
end
