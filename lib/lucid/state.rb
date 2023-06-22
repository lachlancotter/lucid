require "dry-schema"
require "dry-struct"

module Lucid
  #
  # Encapsulates the application state.
  #
  class State < OpenStruct

    class << self
      def attribute (name, options = {})
        @defaults       ||= {}
        @defaults[name] = options[:default]
      end

      def validate (&block)
        @schema = Dry::Schema.Params(&block)
      end

      attr_reader :defaults, :schema
    end

    def initialize(data = {})
      super(schema.call(defaults.merge(data)).to_h)
    end

    def defaults
      self.class.defaults || {}
    end

    def schema
      self.class.schema || default_schema
    end

    def mutate (&block)
      new_state = self.dup
      block.call(new_state) if block_given?
      new_state
    end

    private

    #
    # If no schema is provided, assume every attribute
    # defined is optional.
    #
    def default_schema
      attrs = defaults.keys
      Dry::Schema.Params do
        attrs.each do |key|
          optional(key)
        end
      end
    end
  end
end