require "dry/struct"

module Lucid
  class App
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
        @session_hash = session_hash || {}
        @state        = map_state(@session_hash)
        run_callbacks(:after_initialize)
      end

      def [] (key)
        @session_hash[key.to_s]
      end

      def put (data)
        @state = @state.new(data) # Validation.
        data.each { |key, value| @session_hash[key.to_s] = value }
        data.keys.each { |key| field(key).invalidate if field?(key) }
      end

      private

      def map_state(session_hash)
        self.class.state_class.new(
           Hash[
              session_hash.to_h.map do |key, value|
                [key.to_sym, value]
              end
           ]
        )
      end

      class << self
        def key (name, type = Types.string)
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
end