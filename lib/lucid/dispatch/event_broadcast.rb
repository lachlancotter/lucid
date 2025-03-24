module Lucid
  module EventBroadcast

    #
    # Register a subscriber for the given message class.
    #
    def subscribe (message_class, &block)
      subscribers[message_class] ||= []
      subscribers[message_class] << block
    end

    def subscribes? (message_class)
      subscribers.key?(message_class) ||
         recruits.any? { |r| r.subscribes?(message_class) }
    end

    def subscribers_for (message_class)
      (subscribers[message_class] || []).concat(
         recruits.flat_map { |r| r.subscribers_for(message_class) }
      )
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