require "zeitwerk"
require "pathname"
require "awesome_print"
require "forwardable"
require "rack"

module Lucid
  unless defined?(LOADER)
    LOADER = Zeitwerk::Loader.new
    LOADER.push_dir(__dir__)
    LOADER.collapse("#{__dir__}/lucid/dispatch")
    LOADER.inflector.inflect('htmx' => 'HTMX')
    LOADER.inflector.inflect('http' => 'HTTP')
    LOADER.inflector.inflect('html' => 'HTML')
    LOADER.inflector.inflect('url' => 'URL')
    LOADER.enable_reloading
    LOADER.setup
  end

  #
  # Path to the project root directory.
  #
  def self.root
    Pathname.new(__dir__).ascend do |path|
      return path.to_s if path.join("Gemfile").exist?
    end
  end
end