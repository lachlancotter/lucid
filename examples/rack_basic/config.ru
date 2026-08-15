require_relative "../../lib/lucid"

class RackGreetPerson < Lucid::Link
  validate do
    required(:name).filled(:string)
  end
end

class RackHomePage < Lucid::Component::Base
  param :name, Types.string.default("world".freeze)

  to RackGreetPerson do |msg|
    update(name: msg.name)
  end

  element do |name|
    h1 { text "Hello, #{name}" }
    p { text "This Lucid app is mounted through Rack." }
    p { link_to RackGreetPerson.new(name: "Rack"), "Say hello through Rack" }
  end
end

class RackBasicApp < Lucid::App
  set :component_class, RackHomePage
end

run RackBasicApp
