require "zeitwerk"
require_relative "../../../lib/lucid"

module MusicStore
  unless defined?(LOADER)
    LOADER = Zeitwerk::Loader.new
    layout = Lucid::DirectoryLayout::Project.new("#{__dir__}/..", MusicStore)
    layout.configure(LOADER)
    LOADER.inflector.inflect('htmx' => 'HTMX')
    LOADER.enable_reloading
    LOADER.setup
  end
end