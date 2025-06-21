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
        State::Writer.new(deep_state).tap do |buffer|
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

      private

      def initialize_state (state)
        validate_reader!(state).tap do |reader|
          @state_reader = reader
          @state        = self.class.build_state(reader)
        end
      end

      #
      # Read state for a nested component.
      #
      def nested_state (key)
        Types.reader[@state_reader.seek(self.class.state_map.path_count, key)]
      end

      def validate_reader! (reader)
        case reader
        when State::Reader then reader
        when State::HashReader then reader
        when Hash then State::HashReader.new(reader)
        else raise ArgumentError, "Invalid state: #{reader}"
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
          state_map.param(name, type) unless state_map.path?(name)
        end

        def state_class
          @state_class ||= Class.new(Dry::Struct)
        end

        def state_map
          @state_map ||= State::Map.new
        end

        #
        # Build an instance of the state class from the reader.
        # 
        def build_state (reader)
          data = reader.read(state_map)
          state_class.new(data)
        rescue Dry::Struct::Error => e
          raise ParamError.new(self, data, e.message)
        end
      end
    end
  end
end