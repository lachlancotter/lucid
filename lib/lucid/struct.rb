require "dry-schema"

module Lucid
  #
  # An immutable data structure with a schema, and attribute accessors.
  # Intended to be extended in order to define attributes and validation
  # schema for specific subclasses.
  #
  # Structs are initialized with a hash of attributes. Struct instances
  # may be invalid if the attributes do not conform to the schema. And
  # can return a hash of validation errors.
  #
  class Struct


    def initialize (params = {})
      @params = Check[params].hash.value
    end

    attr_reader :params

    def [] (key)
      validated[key]
    end

    def to_h
      validated.to_h
    end

    def keys
      validated.keys
    end

    def valid?
      errors.empty?
    end

    def errors
      validated.errors.to_h
    end

    private

    def validated
      @validated ||= schema.call(defaults.merge(@params))
    end

    def defaults
      self.class.defaults
    end

    def schema
      self.class.schema
    end

    # ===================================================== #
    #    Class Methods
    # ===================================================== #

    class << self
      #
      # Define attribute accessors and defaults.
      #
      def attribute (name, options = {})
        @attributes       ||= {}
        @attributes[name] = options
        define_method(name) { validated[name] }
      end

      def defaults
        @attributes ||= {}
        @attributes.map { |k, v| [k, v[:default]] }.to_h
      end

      #
      # Define the validation schema.
      #
      def validate (&block)
        @schema = Dry::Schema.Params(&block)
      end

      def schema
        @schema || NilSchema.new
      end
    end

    class NilSchema
      def call (params)
        @params = params
        self
      end

      def [] (key)
        @params[key]
      end

      def to_h
        @params
      end

      def errors
        []
      end
    end

  end
end