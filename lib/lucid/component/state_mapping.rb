module Lucid
  module Component
    #
    # Mapping between component state and URL.
    #
    module StateMapping
      def self.included (base)
        base.extend(ClassMethods)
      end

      attr_reader :state

      #
      # Encodes component state as a URL.
      #
      def url
        State::Writer.new.tap do |buffer|
          buffer.write_component(self, on_route: true)
        end.to_s
      end

      #
      # The state for this and all nested components.
      #
      def deep_state
        state.to_h.tap do |result|
          nests.each do |(name, nest)|
            result[name] = nest.deep_state
          end
        end
      end

      def routes_to? (nest)
        nest.name == self.class.instance_variable_get(:@nested_route_component)
      end

      #
      # Update state-backed values and invalidate dependent fields.
      #
      protected def update (data)
        @state = @state.new(data)
        data.keys.each { |key| field(key).invalidate if field?(key) }
      rescue Dry::Struct::Error => e
        raise StateError.new(self, data, e.message)
      end

      private

      def initialize_state (state)
        validate_state_scope!(state).tap do |scope|
          @state_reader = scope
          @state        = PendingState.new(
             self.class.read_state_data(scope),
             self.class.default_state_data
          )
        end
      end

      def validate_deferred_state!
        @state = self.class.build_state_from_data(@state.to_h)
      end

      def validate_state_scope! (scope)
        case scope
        when State::Scope then scope
        when State::Store then scope.scoped
        when State::HashStore then scope.scoped
        when Hash then State::HashStore.new(scope).scoped
        else raise ArgumentError, "Invalid state: #{scope}"
        end
      end

      #
      # DSL methods.
      # 
      module ClassMethods
        #
        # Define the path mapping for the component state.
        # E.g. route "/:id/:name/literal"
        # 
        def route (pattern, nest: nil)
          segments = pattern.sub(/\A\/+/, '').sub(/\/+\z/, '').split("/")
          segments.each do |s|
            map_key = s.match(/^:(\w+)$/) ? $1.to_sym : s
            state_map.path(map_key)
          end
          @nested_route_component = nest
        end

        #
        # Map a query parameter to a state attribute.
        #
        def param (name, type = Types.string.default("".freeze))
          state_class.attribute(name, type)
          after_initialize { fields[name] = Field.new(self) { state[name] } }
          define_method(name) { fields[name].value }
          state_map.param(name, type) unless state_map.path?(name)
        end

        def state_class
          @state_class ||= Class.new(Dry::Struct)
        end

        def state_map
          @state_map ||= State::Map.new
        end

        def build_state_from_data (data)
          state_class.new(data)
        rescue Dry::Struct::Error => e
          raise ParamError.new(self, data, e.message)
        end

        def read_state_data (cursor)
          cursor.read(state_map)
        end

        def default_state_data
          state_class.schema.keys.each_with_object({}) do |key, defaults|
            defaults[key.name] = key.type[] if key.type.default?
          end
        end
      end

      class PendingState
        def initialize (data, defaults = {})
          @defaults = defaults
          @data     = @defaults.merge(data)
        end

        def [] (key)
          @data[key]
        end

        def new (data)
          self.class.new(@data.merge(data), @defaults)
        end

        def to_h
          @data.to_h
        end
      end
    end
  end
end
