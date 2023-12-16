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
        location = Location.new(deep_state, state_map)
        message ? location + message : location
      end

      # def app_root
      #   @opts.fetch(:app_root, "").sub(/^\/$/, "")
      # end

      private def state_map
        self.class.state_map
      end

      module ClassMethods
        #
        # DSL method for defining the href by projecting path components
        # and params from the component state.
        #
        def map (&block)
          @state_map = block
        end

        #
        # Extract state data from the given href.
        #
        def decode_state (href)
          state_map.decode(href)
        end

        def state_map
          if @state_map.nil?
            State::Map.new
          else
            State::Map.build(
               { nests: nested_state_maps },
               &@state_map
            )
          end
        end

        private def nested_state_maps
          nests.inject({}) do |hrefs, (name, nest)|
            hrefs.merge(name => nest.nested_class.state_map)
          end
        end
      end
    end
  end
end