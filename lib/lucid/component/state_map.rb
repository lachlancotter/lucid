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

      # def valid?
      #   state.valid?
      # end

      #
      # Encodes component state as a URL.
      #
      def href
        State::Writer.new(deep_state).tap do |buffer|
          buffer.write_component(self)
        end.to_s
      end

      #
      # Add the component state to the given message parameters.
      #
      def merge_state (message_params)
        message_params.merge(state: deep_state)
      end

      module ClassMethods
        #
        # Map a path component to a state attribute.
        #
        def path (name, type = Types.string.default("".freeze), in: nil, nest: nil)
          map_attrs(name, type) { |map| map.path(name) }
        end

        #
        # Map a query parameter to a state attribute.
        #
        def param (name, type = Types.string.default("".freeze))
          map_attrs(name, type) { |map| map.param(name) }
        end

        #
        # Dynamically define a state attribute.
        #
        private def map_attrs (name, type)
          state_class.attribute(name, type)
          after_initialize { fields[name] = Field.new(self) { state[name] } }
          yield state_map
        end

        #
        # Define a schema for the component state.
        #
        # def validate (&block)
        #   state_class.validate(&block)
        # end

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
          data = reader.read(state_map)
          state_class.new(data).tap do |state|
            extra_keys = data.keys - state.keys
            unless extra_keys.empty?
              puts "WARNING: Extra keys in state: #{extra_keys.inspect}. Ignoring."
            end
          end
        end
      end
    end
  end
end