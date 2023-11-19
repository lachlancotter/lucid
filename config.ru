$LOAD_PATH.unshift(File.dirname(__FILE__) + "/lib")
$LOAD_PATH.unshift(File.dirname(__FILE__) + "/lib/app")

require "sinatra/base"
require "awesome_print"
require "shopping/app"

Shopping::App.run!