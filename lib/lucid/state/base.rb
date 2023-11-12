require "dry-schema"
require "dry-struct"

module Lucid
  module State
    #
    # Encapsulates the application state.
    #
    class Base

      def initialize(data = {})
        @data = immutable(validated(data))
      end

      def immutable (data)
        Immutable::Hash[data.map { |k, v| [k, v] }]
      end

      def validated (data)
        if schema
          schema.call(defaults.merge(data)).to_h
        else
          defaults.merge(data)
        end
      end

      def defaults
        self.class.defaults || {}
      end

      def to_h
        @data.to_h
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
        @data = immutable(
           validated(
              @data.merge(data)
           )
        )
      end

      #
      # Yields a copy of the state to the block along with any
      # additional arguments. The block can modify the new state
      # using the update method. Does not modify the original.
      #
      def transform (*args, &block)
        dup.tap do |new_state|
          block.call(new_state, *args)
        end
      end

      # def merge (other)
      #   self.class.new(self.to_h.merge(other.to_h))
      # end

      # ===================================================== #
      #    Class Methods
      # ===================================================== #

      class << self
        #
        # Define an attribute.
        #
        def attribute (name, options = {})
          @defaults       ||= {}
          @defaults[name] = options[:default]
        end

        #
        # Define validation rules.
        #
        def validate (&block)
          @schema = Dry::Schema.Params(&block)
        end

        attr_reader :defaults, :schema
      end

    end
  end
end