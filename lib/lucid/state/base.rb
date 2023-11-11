require "dry-schema"
require "dry-struct"

module Lucid
  module State
    #
    # Encapsulates the application state.
    #
    class Base < OpenStruct

      def initialize(data = {})
        if schema
          super(schema.call(defaults.merge(data)).to_h)
        else
          super(defaults.merge(data))
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

      def empty?
        to_h.empty?
      end

      def schema
        self.class.schema
      end

      def mutate (&block)
        new_state = self.dup
        block.call(new_state) if block_given?
        new_state
      end

      def merge (other)
        self.class.new(self.to_h.merge(other.to_h))
      end

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