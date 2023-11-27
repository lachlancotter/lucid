require "lucid/struct"
require "lucid/busable"

module Lucid
  #
  # Base class for events.
  #
  class Event < Struct
    extend Busable

    class << self
      #
      # Define the event data.
      #
      # def params (&block)
      #   @params_class = Class.new(State::Base, &block)
      # end
      #
      # def params_class
      #   @params_class ||= Class.new(State::Base)
      # end
      #
      # def validate (&block) end

      def notify (data)
        new(data).notify
      end
    end

    # def initialize (data)
    #   @data = self.class.params_class.new(data)
    # end

    # attr_reader :data

    def notify
      Event.bus.notify(self)
    end
  end
end