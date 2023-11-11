module Lucid
  #
  # Enables configuration of a message bus shared between instances
  # of a message class. This allows the bus instance to be injected
  # in controller code, and used implicitly by the message class.
  #
  module Busable
    # Class variable to store the shared bus instance.
    attr_reader :bus

    # Make a bus instance available to the message class
    # for the duration of the block.
    def with_bus (bus, &block)
      old_bus  = @bus
      @bus = bus
      block.call
    ensure
      @bus = old_bus
    end
  end
end