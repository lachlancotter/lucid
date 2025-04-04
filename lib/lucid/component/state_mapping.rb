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
        subcomponents.inject(state.to_h) do |hash, (name, sub)|
          case sub
          when Component::Base
            hash.merge(name => sub.deep_state)
          when Collection
            hash.merge(
               name => sub.map do |e|
                 { e.collection_key => e.deep_state }
               end
            )
          else
            raise "Unexpected subcomponent type: #{sub.class}"
          end
        end
      end

      def routes_to? (nest)
        nest.name == self.class.instance_variable_get(:@nested_route_component)
      end

      #
      # Add the component state to the given message parameters.
      #
      def merge_state (message_params)
        message_params.merge(state: deep_state)
      end

      private

      def initialize_state (reader_data)
        validate_reader!(reader_data).tap do |reader|
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

      def validate_reader! (value)
        case value
        when State::Reader then value
        when State::HashReader then value
        when Hash then State::HashReader.new(value)
        else raise ArgumentError, "Invalid state: #{value}"
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
          state_map.param(name) unless state_map.path?(name)
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
          raise Invalid.new(self, data, e.message)
        end
      end

      class Invalid < ArgumentError
        def initialize (component, data, message)
          super("Invalid state for #{component}: #{data.inspect}. #{message}")
        end
      end
    end
  end
end