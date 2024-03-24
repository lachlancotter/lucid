require "zeitwerk"
require "awesome_print"
require "./lib/check"

module Lucid

end

module Shopping

end

unless defined?(LOADER)
  LOADER = Zeitwerk::Loader.new
  LOADER.push_dir("./lib/lucid", namespace: Lucid)
  LOADER.push_dir("./lib/app/shopping/models", namespace: Shopping)
  LOADER.push_dir("./lib/app/shopping/events", namespace: Shopping)
  LOADER.push_dir("./lib/app/shopping/commands", namespace: Shopping)
  LOADER.push_dir("./lib/app/shopping/links", namespace: Shopping)
  LOADER.push_dir("./lib/app/shopping/views", namespace: Shopping)
  LOADER.push_dir("./lib/app/shopping/actions", namespace: Shopping)
  LOADER.enable_reloading
  LOADER.setup
end

%w[models events commands links views].each do |dir|
  path = "./lib/app/shopping/#{dir}"
  Dir["#{path}/*.rb"].each do |f|
    puts f
    require f
  end
end

Shopping::Session.init

require "app/shopping/app"
# Shopping::App

# %w[models commands events links views].each do |dir|
#   Dir["./lib/app/shopping/#{dir}/*.rb"].each do |f|
#     puts f
#     require f
#   end
# end
#
# require "app/shopping/app"