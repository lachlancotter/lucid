module Lucid
  #
  # Decides whether a message should be processed by a component by matching
  # on the message type as well as optional constraints on the message fields.
  # Values from the message are matched against corresponding values in the
  # given context (typically a component).
  #
  class MessageFilter
    def initialize (message_class, *keys, **maps)
      @message_class = message_class
      @keys          = keys
      @maps          = maps
    end

    def match? (message, context = {})
      return false unless message.is_a?(@message_class)
      return false unless all_keys_match?(context, message)
      return false unless all_maps_match?(context, message)
      true
    end

    private

    def all_keys_match?(context, message)
      @keys.all? { |key| key_match?(key, message, context) }
    end

    def key_match? (key, message, context)
      message[key] == context[key]
    end

    def all_maps_match?(context, message)
      @maps.all? { |key, value| map_match?(key, value, message, context) }
    end

    def map_match? (key, value, message, context)
      message[key] == case value
      when Symbol then context[value]
      else value
      end
    end
  end
end