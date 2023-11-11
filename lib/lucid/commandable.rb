module Lucid
  module Commandable
    def self.included (base)
      base.extend(ClassMethods)
    end

    def dispatch_command (command)
      # TODO extract to command bus.
      if performs?(command)
        perform(command)
      else
        raise "No handler for #{command.class}"
      end
    end

    def perform (command)
      # TODO add validation... maybe in the bus.
      self.class.actions.fetch(command.class).call(command)
    end

    def performs? (command)
      self.class.actions.key?(command.class)
    end

    module ClassMethods
      #
      # Register an action for the given command class.
      #
      def perform (command_class, &block)
        @actions                ||= {}
        @actions[command_class] = block
      end

      attr_reader :actions
    end
  end
end