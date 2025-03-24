module Lucid
  #
  # Dispatch commands to their handlers.
  #
  class Dispatcher
    #
    # Config is a Handler class that defines the handlers for the commands.
    #
    def initialize (dispatch_config, container = nil)
      @dispatch_config = dispatch_config
      @container       = container
    end

    def dispatch (message)
      handler_for(message).call(message)
    end

    def handler_for (message)
      klass, block = @dispatch_config.find_handler(message.class)
      klass.new(&block)
    end
  end
end