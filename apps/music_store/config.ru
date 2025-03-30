# $LOAD_PATH.unshift(File.dirname(__FILE__) + "/lib")
# $LOAD_PATH.unshift(File.dirname(__FILE__) + "/lib/app")

require_relative "./boot"

MusicStore::App.run!