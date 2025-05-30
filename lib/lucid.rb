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
  
  # ===================================================== #
  #    Error Types
  # ===================================================== #
  
  class RequestError < StandardError
    # Base class for errors in the request.
  end
  
  # Maybe it should be called InvalidState
  class ParamError < RequestError
    def initialize (component, data, message)
      super("Invalid params for #{component}: #{data.inspect}. #{message}")
    end
  end

  class PermissionError < RequestError
    def initialize (component)
      super("Permission denied for #{component}.")
    end
  end
  
  class ResourceError < RequestError
    def initialize (component, resource)
      super("Missing resource #{resource}")
    end
  end
  
  class ApplicationError < StandardError
    # Base class for error in the application.
  end
  
  class ConfigError < ApplicationError
    def initialize (component, config, message)
      super("Invalid props given to #{component}: #{message}")
    end
  end
  
  class StateError < ApplicationError
    def initialize (component, state, message)
      super("Invalid state #{state} applied to #{component}: #{message}")
    end
  end
  
  # ===================================================== #
  #    System Events
  # ===================================================== #

  #
  # Published when an invalid message is received.
  # 
  class MessageInvalidated < Event
    validate do
      required(:params).filled
    end
  end
  
  #
  # Published when a handler cannot be run due to a policy.
  # 
  class PermissionDenied < Event
    validate do
      required(:message).filled
    end
  end

  #
  # Published when a handler raises an error.
  # 
  class HandlerRaised < Event
    validate do
      required(:error).filled
    end
  end
  
end