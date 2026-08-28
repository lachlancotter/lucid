require_relative "../../lib/lucid"

class GreetPerson < Caju::Link
  validate do
    required(:name).filled(:string)
  end
end

class HomePage < Caju::Component::Base
  param :name, Types.string.default("world".freeze)

  to GreetPerson do |msg|
    update(name: msg.name)
  end

  element do |name|
    h1 { text "Hello, #{name}" }
    p { text "Caju rebuilds this component from URL-backed state." }
    p { link_to GreetPerson.new(name: "Caju"), "Say hello to Caju" }
  end
end

class ExampleApp < Caju::App
  set :component_class, HomePage
end

ExampleApp.run! if $PROGRAM_NAME == __FILE__
