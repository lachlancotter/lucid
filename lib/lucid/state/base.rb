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

      def initialize(data = {})
        @data = validated(defaults.merge(data))
        raise Invalid, self unless valid?
      end

      def [] (key)
        @data[key]
      end

      def key? (key)
        @data.key?(key)
      end

      def to_h
        @data.to_h
      end

      # def immutable (data)
      #   Immutable::Hash[data.map { |k, v| [k, v] }]
      # end

      def validated (data)
        if schema
          schema.call(data).to_h
        else
          data
        end
      end

      def defaults
        self.class.defaults || {}
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

      #
      # Yields a copy of the state to the block along with any
      # additional arguments. The block can modify the new state
      # using the update method. Does not modify the original.
      #
      # def transform (*args, &block)
      #   dup.tap do |new_state|
      #     block.call(new_state, *args)
      #   end
      # end

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
        def attribute (name, **options)
          @attributes ||= []
          @attributes << name
          @defaults       ||= {}
          @defaults[name] = options[:default]
          define_method(name) { self[name] }
        end

        def attributes
          @attributes || []
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