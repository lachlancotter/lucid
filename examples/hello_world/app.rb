require_relative "../../lib/lucid"

class GreetPerson < Lucid::Link
  param :name, String
end

class HomePage < Lucid::Component::Base
  param :name, Types.string.default("world".freeze)

  to GreetPerson do |msg|
    update(name: msg.name)
  end

  element do |name|
    h1 { text "Hello, #{name}" }
    p { text "Lucid rebuilds this component from URL-backed state." }
    p { link_to GreetPerson.new(name: "Lucid"), "Say hello to Lucid" }
  end
end

class ExampleApp < Lucid::App
  set :component_class, HomePage
end

ExampleApp.run! if $PROGRAM_NAME == __FILE__
