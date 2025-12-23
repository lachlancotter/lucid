Gem::Specification.new do |spec|
  spec.name          = "lucid"
  spec.version       = "0.1.5"
  spec.authors       = ["Lachlan Cotter"]
  spec.email         = ["lach@satoriapp.com"]
  spec.summary       = "Reactive, hypermedia components for Ruby"
  spec.description   = "Lucid is a component-based framework for building reactive, hypermedia applications in Ruby. " +
                       "It provides a set of tools and abstractions to create modular, reusable components that can be " +
                       "easily composed to build complex user interfaces."
  spec.homepage      = "https://github.com/lachlancotter/lucid"
  spec.license       = "MIT"
  spec.files         = Dir["lib/**/*", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "rack"
  spec.add_dependency "zeitwerk"
  spec.add_dependency "sinatra"
  spec.add_dependency "docile" # Build DSLs.
  spec.add_dependency "dry-types" # Type checking.
  spec.add_dependency "dry-struct" # Component state and props.
  spec.add_dependency "dry-schema" # Message validation.
  spec.add_dependency "papercraft" # Generate HTML from Ruby.
  spec.add_dependency "htmlbeautifier" # Pretty-print HTML.
  spec.add_dependency "console" # Pretty console logging.
  spec.add_dependency "binding_of_caller" # For assertions.
end
