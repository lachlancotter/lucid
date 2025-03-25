require "rack/test"
require_relative "../server"

ENV["RACK_ENV"]                = "test"
Satori::Server.environment = :test