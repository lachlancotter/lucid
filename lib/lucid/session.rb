module Lucid
  #
  # Base class for Session objects. A Session stores and updates data to be
  # preserved across multiple requests. Lucid Sessions have a schema that
  # validates the data they store, and observable attributes that trigger
  # notifications when they change.
  #
  class Session
    include Component::Callbacks

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

    def field (name)
      raise Component::Field::NoSuchField.new(name, "session") unless field?(name)
      fields[name]
    end

    def field? (name)
      fields.key?(name)
    end

    def fields
      @fields ||= {}
    end

    def watch (*keys, &block)
      keys.each { |key| field(key).attach(self, &block) }
    end

    #
    # DSL
    #
    class << self
      def attribute (name, default: nil, &constructor)
        attributes[name] = State::Base::Attribute.new(name, default: default, &constructor)
        after_initialize { fields[name] = Component::Field.new(self) { self[name] } }
        define_method(name) { self[name] }
      end

      def attributes
        @attributes ||= Match.on(superclass) do
          responds_to(:attributes) { |sc| sc.attributes.dup }
          default { {} }
        end
      end

      def map_attributes (&block)
        attributes.map { |name, attr| [name, block.call(attr)] }.to_h
      end

      def let (name, &block)
        after_initialize { fields[name] = Component::Field.new(self, &block) }
        define_method(name) { fields[name].value }
      end

      def validate (&block)
        @schema = Dry::Schema.Params(&block)
      end

      attr_reader :schema
    end
  end
end