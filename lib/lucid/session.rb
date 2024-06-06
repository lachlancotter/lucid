module Lucid
  #
  # Base class for Session objects. A Session stores and updates data to be
  # preserved across multiple requests. Lucid Sessions have a schema that
  # validates the data they store, and observable attributes that trigger
  # notifications when they change.
  #
  class Session
    include Component::Callbacks
    include Fields

    def initialize (session_hash)
      @session_hash = session_hash
      @state        = self.class.state_class.new(session_hash.to_h)
      run_callbacks(:after_initialize)
    end

    def [] (key)
      @session_hash[key]
    end

    def put (data)
      @state = @state.new(data) # Validation.
      @session_hash.merge!(@state.to_h)
      data.keys.each { |key| field(key).invalidate if field?(key) }
    end

    class << self
      def attribute (name, type = Types.string)
        state_class.attribute(name, type)
        after_initialize { fields[name] = Field.new(self) { self[name] } }
        define_method(name) { self[name] }
      end

      def state_class
        @state_class ||= Class.new(Dry::Struct)
      end
    end
  end
end