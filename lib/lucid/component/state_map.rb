module Lucid
  module Component
    #
    # Mapping between component state and URL.
    #
    module StateMap
      def self.included (base)
        base.extend(ClassMethods)
      end

      private def init_state (data)
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

      def valid?
        state.valid?
      end

      #
      # Encodes component state as a URL.
      #
      def href
        State::Writer.new(deep_state).tap do |buffer|
          buffer.write_component(self)
        end.to_s
      end

      module ClassMethods
        #
        # Map a path component to a state attribute.
        #
        def path (*args, default: nil, defaults: [], in: nil, nest: nil)
          map_attrs(*args, default: default, defaults: defaults) do |map, name, index|
            map.path(name, index)
          end
        end

        #
        # Map a query parameter to a state attribute.
        #
        def param (*args, default: nil, defaults: [])
          map_attrs(*args, default: default, defaults: defaults) do |map, name|
            map.param(name)
          end
        end

        #
        # Dynamically define a state attribute.
        #
        private def map_attrs (*args, default: nil, defaults: [])
          args.each_with_index do |name, index|
            state_class.attribute(name, default: defaults[index] || default)
            after_initialize { fields[name] = Field.new(self) { state[name] } }
            yield state_map, name, index
          end
        end

        #
        # Define a schema for the component state.
        #
        def validate (&block)
          state_class.validate(&block)
        end

        def state_class
          @state_class ||= Class.new(State::Base)
        end

        def state_map
          @state_map ||= State::Map.new
        end

        #
        # Instantiate a state object from the given data.
        #
        def build_state (reader)
          Check[reader].type(State::Reader, State::HashReader)
          state_class.new(reader.read(state_map)).tap do |state|
            extra_keys = reader.read(state_map).keys - state.keys
            unless extra_keys.empty?
              puts "WARNING: Extra keys in state: #{extra_keys.inspect}. Ignoring."
            end
          end
        end
      end
    end
  end
end