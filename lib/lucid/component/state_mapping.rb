module Lucid
  module Component
    #
    # Mapping between component state and URL.
    #
    module StateMapping
      def self.included (base)
        base.extend(ClassMethods)
      end

      private def initialize_state (data)
        Match.on(data) do
          type(State::Reader) { data }
          type(State::HashReader) { data }
          type(Hash) { State::HashReader.new(data) }
          default { raise ArgumentError, "Invalid state: #{data}" }
        end.tap do |params|
          @params = params
          @state  = self.class.build_state(params)
        end
      end

      attr_reader :state

      # def valid?
      #   state.valid?
      # end

      #
      # Encodes component state as a URL.
      #
      def url
        State::Writer.new(deep_state).tap do |buffer|
          buffer.write_component(self, on_route: true)
        end.to_s
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
        # Instantiate a state object from the given data.
        #
        def build_state (reader)
          Check[reader].type(State::Reader, State::HashReader)
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