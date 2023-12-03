module Lucid
  module Commandable
    def self.included (base)
      base.extend(ClassMethods)
    end

    def dispatch (command)
      if performs?(command)
        Logger.command(command)
        perform(command)
      else
        raise NoHandlerError.new(command)
      end
    end

    def perform (command)
      self.class.command_handlers.fetch(command.class).call(command)
    end

    def performs? (command)
      self.class.command_handlers.key?(command.class)
    end

    class NoHandlerError < StandardError
      def initialize (command)
        super("No handler for command #{command.class}")
      end
    end

    module ClassMethods
      #
      # Register a handler for the given command class.
      #
      def perform (command_class, &block)
        @command_handlers                ||= {}
        @command_handlers[command_class] = block
      end

      def command_handlers
        @command_handlers || {}
      end
    end
  end
end