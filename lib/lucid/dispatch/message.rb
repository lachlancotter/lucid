require "dry-struct"
require "dry-schema"

module Lucid
  class Message

    def initialize (params = {})
      self.class.schema.call(params).tap do |result|
        Invalid.check(self.class, result)
        @params = result.to_h
      end
    end

    def to_h
      @params.to_h
    end

    def [] (key)
      @params[key]
    end

    # ===================================================== #
    #    Class Methods
    # ===================================================== #

    class << self
      def validate (&block)
        @schema = Dry::Schema.Params(&block)
        @schema.rules.each do |(name, rule)|
          define_method(name) { @params[name] }
        end
      end

      def schema
        @schema || NilSchema.new
      end

      def valid? (data)
        schema.call(data).success?
      end

      def [] (*keys, **maps)
        Constraint.new(self, *keys, **maps)
      end
    end

    # ===================================================== #
    #    Errors
    # ===================================================== #

    class Invalid < ArgumentError
      def initialize (message_class, errors)
        super("#{message_class}: #{errors.to_h}")
      end

      def self.check (message_class, result)
        raise new(message_class, result.errors) unless result.success?
      end
    end

    # ===================================================== #
    #    NilSchema
    # ===================================================== #

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

      def success?
        true
      end
    end
  end
end