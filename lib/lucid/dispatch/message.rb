require "dry-struct"
require "dry-schema"

module Lucid
  class Message
    class Invalid < ArgumentError
      def initialize (message_class, errors)
        super("#{message_class}: #{errors.to_h}")
      end
    end

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

    def initialize (params = {})
      self.class.schema.call(params).tap do |result|
        raise Invalid.new(self.class, result.errors) unless result.success?
        @params = result.to_h
      end
    end

    def to_h
      @params.to_h
    end

    def [] (key)
      @params[key]
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

      def success?
        true
      end
    end
  end
end