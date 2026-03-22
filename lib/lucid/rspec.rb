module Lucid
  module RSpec
    if defined?(::RSpec)
      ::RSpec.configure do |config|
        config.include Components::ExampleExtensions, type: :component
        config.extend Components::ExampleGroupExtensions, type: :component
        config.include Handlers::ExampleExtensions, type: :handler
        config.extend Handlers::ExampleGroupExtensions, type: :handler
      end
    end
  end
end