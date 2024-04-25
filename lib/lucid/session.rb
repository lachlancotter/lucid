module Lucid
  #
  # Base class for Session objects. A Session stores and updates data to be
  # preserved across multiple requests. Lucid Sessions have a schema that
  # validates the data they store, and observable attributes that trigger
  # notifications when they change.
  #
  class Session
    include Component::Callbacks
    include Attributes
    include Fields

    #
    # Indicates that the Session data is invalid.
    #
    class Invalid < StandardError
      def initialize (errors)
        super(errors.inspect)
      end
    end

    def initialize (data)
      @session_hash = data
      self.class.map_attributes { |attr| attr.build(data) }.tap do |new_data|
        validate!(new_data)
        @session_hash.merge!(new_data)
      end
      run_callbacks(:after_initialize)
    end

    def [] (key)
      @session_hash[key]
    end

    def put (data)
      @session_hash.to_h.merge(data).tap do |new_data|
        validate!(new_data)
        @session_hash.merge!(new_data)
        data.keys.each do |key|
          field(key).invalidate if field?(key)
        end
      end
    end

    def validate! (data)
      return unless self.class.schema
      result = self.class.schema.call(data)
      raise Invalid.new(result.errors.to_h) if result.failure?
    end

    #
    # DSL
    #
    class << self
      def validate (&block)
        @schema = Dry::Schema.Params(&block)
      end

      attr_reader :schema
    end
  end
end