module Lucid
  module Validated
    def self.included (base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def validate (&block)
        @schema = Dry::Schema.Params(&block)
      end

      attr_reader :schema
    end
  end
end