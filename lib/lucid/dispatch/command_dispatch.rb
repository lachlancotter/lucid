module Lucid
  #
  # Methods for configuring the dispatch of commands to their handlers.
  #
  module CommandDispatch
    #
    # Raised when no handler is found for the given command.
    #
    class NoHandler < StandardError
      def initialize (command)
        super("No handler for command #{command.class}")
      end
    end

    #
    # Raised when attempting to register multiple handlers for the same
    # command class either directly or via nested handler recruitment.
    #
    class AmbiguousDispatch < StandardError
      def initialize (command_class)
        super("Ambiguous dispatch for #{command_class}")
      end
    end

    #
    # Register a handler for the given command class.
    #
    def perform (command_class, &block)
      if performs?(command_class)
        raise AmbiguousDispatch.new(command_class)
      end
      handlers[command_class] = block
    end

    #
    # Returns whether the handler can perform the given command class.
    #
    def performs? (command_class)
      handlers.key?(command_class) ||
         recruits.any? { |r| r.performs?(command_class) }
    end

    #
    # Extend the Handler with the handlers of the given delegate class.
    #
    def recruit (delegate_class)
      handlers.keys.each do |command_class|
        if delegate_class.performs?(command_class)
          raise AmbiguousDispatch.new(command_class)
        end
      end
      recruits << delegate_class
    end

    #
    # Returns an array containing the matching Handler class and block
    # for the given command class.
    #
    def find_handler (command_class)
      handler = handlers[command_class]
      if handler
        [self, handler]
      else
        find_nested_handler(command_class)
      end.tap do |result|
        raise NoHandler.new(command_class) unless result
      end
    end

    def find_nested_handler (command_class)
      # Return the result of the first block that is truthy.
      recruits.lazy.map do |delegate|
        delegate.find_handler(command_class)
      end.find(&:itself)
    end

    def handlers
      @handlers ||= {}
    end

    def recruits
      @recruits ||= []
    end

  end
end