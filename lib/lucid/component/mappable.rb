require "lucid/location"
require "lucid/state/map"

module Lucid
  module Component
    #
    # A component that can be referenced by a URL.
    #
    module Mappable
      def self.included (base)
        base.extend(ClassMethods)
      end

      #
      # Encodes an href from the receiver and the given message.
      #
      def href (message = nil)
        State::Writer.new(deep_state).tap do |buffer|
          buffer.write_component(self)
          buffer.write_message(message) unless message.nil?
        end.to_s
      end

      # def app_root
      #   @opts.fetch(:app_root, "").sub(/^\/$/, "")
      # end

      def state_map
        self.class.state_map
      end

      # private def nested_state_maps
      #   nests.inject({}) do |hrefs, (name, nest)|
      #     hrefs.merge(name => nest.nested_class.state_map)
      #   end
      # end

      module ClassMethods
        #
        # DSL method for defining the href by projecting path components
        # and params from the component state.
        #
        def map (&block)
          # @state_map = block
        end

        def path (*args, default: nil, defaults: [], nest: nil)
          map_attrs(*args, default: default, defaults: defaults) do |map, name, index|
            map.path(name, index)
          end
        end

        def param (*args, default: nil, defaults: [])
          map_attrs(*args, default: default, defaults: defaults) do |map, name|
            map.param(name)
          end
        end

        private def map_attrs (*args, default: nil, defaults: [])
          @state_class ||= Class.new(State::Base)
          @state_map   ||= State::Map.new
          args.each_with_index do |name, index|
            @state_class.attribute(name, default: defaults[index] || default)
            define_method(name) { state.send(name) }
            yield @state_map, name, index
          end
        end

        def validate (&block)
          @state_class ||= Class.new(State::Base)
          @state_class.validate(&block)
        end

        #
        # Extract state data from the given href.
        #
        # def decode_state (href)
        #   State::Reader.new(href).read(self.state_map)
        # end

        def state_map
          @state_map || State::Map.new
          # if @state_map.nil?
          #   State::Map.new
          # else
          #   State::Map.build(
          #      { nests: nested_state_maps },
          #      &@state_map
          #   )
          # end
        end
      end
    end
  end
end