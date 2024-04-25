require "dry-schema"
require "immutable/hash"

module Lucid
  module State
    class Invalid < StandardError
      def initialize(state)
        super(
           <<~MSG
             Invalid state: 
              #{state.errors.to_h}
              ---
              #{state.to_h}
           MSG
        )
      end
    end

    #
    # Encapsulates the application state.
    #
    class Base
      extend Forwardable
      include Component::Callbacks
      include Attributes

      def initialize(data = {})
        @data = validated(
           self.class.map_attributes do |attr|
             attr.build(data)
           end
        )
        raise Invalid, self unless valid?
      end

      def_delegators :@data, :[], :keys, :key?, :to_h

      def validated (data)
        if schema
          schema.call(data).to_h
        else
          data
        end
      end

      def == (other)
        if other.is_a?(Hash)
          to_h.eql?(other)
        else
          super(other)
        end
      end

      def inspect
        "<State #{to_h}>"
      end

      def valid?
        schema ? schema.call(to_h).success? : true
      end

      def errors
        schema.call(to_h).errors
      end

      def empty?
        @data.empty?
      end

      def schema
        self.class.schema
      end

      #
      # Merges the new data into the state, modifying this object.
      #
      def update (data)
        @data = validated(@data.merge(data))
      end

      # ===================================================== #
      #    Class Methods
      # ===================================================== #

      class << self
        #
        # Define validation rules.
        #
        def validate (&block)
          @schema = Dry::Schema.Params(&block)
        end

        attr_reader :schema
      end
    end
  end
end