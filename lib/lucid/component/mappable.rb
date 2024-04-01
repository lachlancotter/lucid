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
      # Encodes component state as a URL.
      #
      def href
        State::Writer.new(deep_state).tap do |buffer|
          buffer.write_component(self)
        end.to_s
      end

      module ClassMethods
        def path (*args, default: nil, defaults: [], in: nil, nest: nil)
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
          args.each_with_index do |name, index|
            state_class.attribute(name, default: defaults[index] || default)
            after_initialize { fields[name] = Field.new(self) { state[name] } }
            define_method(name) { state.send(name) }
            yield state_map, name, index
          end
        end

        def validate (&block)
          state_class.validate(&block)
        end

        def state_class
          @state_class ||= Class.new(State::Base)
        end

        def state_map
          @state_map ||= State::Map.new
        end
      end
    end
  end
end