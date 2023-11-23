require "lucid/location"

module Lucid
  module Component
    #
    # A component that can be referenced by a URL.
    #
    module Referable
      def self.included (base)
        base.extend(ClassMethods)
      end

      #
      # Encodes an href from the receiver and the given message.
      #
      def href (message = nil)
        location = Location.new(deep_state, href_map)
        message ? location + message : location
      end

      private def href_map
        self.class.href_map(href_config)
      end

      private def href_config
        { app_root: app_root }
      end

      module ClassMethods
        #
        # DSL method for defining the href by projecting path components
        # and params from the component state.
        #
        def href (&block)
          @href_def = block
        end

        #
        # Extract state data from the given href.
        #
        def decode_href (href, config)
          href_map(config).decode(href)
        end

        def href_map (config)
          if @href_def.nil?
            Location::Map.new(config)
          else
            Location::Map.build(
               config.merge(nests: nested_href_maps(config)),
               &@href_def
            )
          end
        end

        private def nested_href_maps (config)
          nests.inject({}) do |hrefs, (name, nest)|
            hrefs.merge(name => nest.nested_class.href_map(config))
          end
        end
      end
    end
  end
end