require_relative "../../lib/lucid"

class SinatraGreetPerson < Lucid::Link
  validate do
    required(:name).filled(:string)
  end
end

class SinatraHomePage < Lucid::Component::Base
  param :name, Types.string.default("world".freeze)

  to SinatraGreetPerson do |msg|
    update(name: msg.name)
  end

  element do |name|
    h1 { text "Hello, #{name}" }
    p { text "This Lucid app is running directly through Sinatra." }
    p { link_to SinatraGreetPerson.new(name: "Sinatra"), "Say hello through Sinatra" }
  end
end

class SinatraBasicApp < Lucid::App
  set :component_class, SinatraHomePage
end

SinatraBasicApp.run! if $PROGRAM_NAME == __FILE__
