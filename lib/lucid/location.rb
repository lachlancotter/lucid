require "rack"
require "docile"
require "lucid/path"

module Lucid
  #
  # Encode the state of a component tree as a URL.
  #
  class Location
    def initialize (state, map)
      @state = state
      @map   = map
    end

    attr_reader :state

    def to_s
      writer = State::Writer.new(state)
      writer.write(@map)
      writer.to_s
    end

    #
    # Create a new location by adding a message to the
    # current state.
    #
    def + (message)
      message_params = message.query_params
      Location.new(
         @state.merge(message_params),
         @map.dup.tap do |map|
           message_params.keys.each do |key|
             map.rules << Map::Param.new(key)
           end
         end
      )
    end

  end
end