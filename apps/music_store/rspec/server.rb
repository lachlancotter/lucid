require "rack/test"
require_relative "../server"

ENV["RACK_ENV"]                = "test"
MusicStore::Server.environment = :test