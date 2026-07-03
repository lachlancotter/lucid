module Lucid
  #
  # Dispatch events to the component and handler.
  # 
  class MessageBus
    MAX_MESSAGES_PER_DRAIN = 1000

    class QueueOverflow < ApplicationError
      def initialize (limit)
        super("Message queue exceeded #{limit} messages while draining")
      end

      def self.check (processed, limit)
        raise new(limit) if processed > limit
      end
    end

    class InvalidMessage < ApplicationError
      def initialize (message)
        super("Message bus cannot process #{message.class}")
      end

      def self.check (message, type)
        raise new(message) unless message.is_a?(type)
      end
    end

    class UndispatchableMessage < ApplicationError
      def initialize (message)
        super("Message bus cannot dispatch #{message.class}")
      end

      def self.check (handler, message)
        raise new(message) if handler && message.is_a?(Command) && !handler.performs?(message.class)
      end
    end

    def initialize (handler, container)
      # @component = Types.component.optional[component]
      @handler   = Types.handler.optional[handler]
      @container = Types.container.optional[container]
      @published = []
      @queue     = []
      @draining  = false
    end

    attr_reader :published

    def dispatch (command)
      InvalidMessage.check(command, Command)
      UndispatchableMessage.check(@handler, command)
      enqueue(command)
      drain unless draining?
    end

    def publish (event)
      InvalidMessage.check(event, Event)
      @published << event
      enqueue(event)
      drain unless draining?
      # @component.apply(event) if @component
    end

    def to_s
      "<#{self.class.name} #{object_id}>"
    end

    def inspect
      to_s
    end

    private

    def enqueue (message)
      @queue << message
    end

    def drain
      @draining = true
      processed = 0

      until @queue.empty?
        processed += 1
        QueueOverflow.check(processed, MAX_MESSAGES_PER_DRAIN)

        process(@queue.shift)
      end
    ensure
      @draining = false
    end

    def draining?
      @draining
    end

    def process (message)
      case message
      when Command
        @handler.dispatch(message, @container) if @handler
      when Event
        @handler.publish(message, @container) if @handler
      else
        InvalidMessage.check(message, Command)
      end
    end
  end
end
