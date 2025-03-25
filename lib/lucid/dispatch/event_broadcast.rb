module Lucid
  #
  # Pub/sub for events. Multiple subscribers can register for the same event
  # and will be called in the order they were registered.
  # 
  module EventBroadcast

    #
    # Raised on an attempt to publish a message that is not an event.
    # 
    class InvalidEvent < StandardError
      def initialize (event)
        super("Message is not a valid event: #{event.class}")
      end

      def self.check (message)
        raise new(message) unless message.is_a?(Event)
      end
    end

    #
    # Register a subscriber for the given message class.
    #
    def subscribe (event_class, &handler_block)
      subscribers[event_class] ||= []
      subscribers[event_class] << handler_block
    end

    def subscribes? (event_class)
      subscribers.key?(event_class) ||
         recruits.any? { |r| r.subscribes?(event_class) }
    end

    def subscribers_for (event_class)
      (subscribers[event_class] || []).concat(
         recruits.flat_map { |r| r.subscribers_for(event_class) }
      )
    end

    def each_subscriber (event_class, &block)
      (subscribers[event_class] || []).each { |handler| yield self, handler }
      recruits.each { |recruit| recruit.each_subscriber(event_class, &block) }
    end

    def publish (event, context)
      InvalidEvent.check(event)
      each_subscriber(event.class) do |klass, handler_block|
        klass.new(context, &handler_block).call(event)
      end
    end

    #
    # Extend the Handler with the handlers of the given delegate class.
    #
    def recruit (delegate_class)
      recruits << delegate_class
    end

    def subscribers
      @subscribers ||= {}
    end

    def recruits
      @recruits ||= []
    end

  end
end