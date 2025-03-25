require "zeitwerk"

module Satori
  unless defined?(Loader)
    Loader = Zeitwerk::Loader.new
    layout = Lucid::DirectoryLayout::Project.new("#{__dir__}/..", Satori)
    layout.configure(Loader)
    Loader.inflector.inflect('htmx' => 'HTMX')
    Loader.enable_reloading
    Loader.setup
  end
end