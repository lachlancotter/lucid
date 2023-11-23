module Lucid
  #
  # Dispatches commands to their handlers.
  #
  class CommandBus

    def initialize
      @handlers = {}
    end

    def register (command_class, &block)
      if @handlers.key?(command_class)
        raise "Command #{command_class} already registered."
      else
        @handlers[command_class] = block
      end
    end

    def dispatch (command)
      @handlers.fetch(command.class).call(command)
    end

  end
end