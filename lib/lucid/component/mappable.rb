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
      def href
        State::Writer.new(deep_state).tap do |buffer|
          buffer.write_component(self)
          # buffer.write_message(message) unless message.nil?
        end.to_s
      end

      def state_map
        self.class.state_map
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
          @state_class ||= Class.new(State::Base)
          @state_map   ||= State::Map.new
          args.each_with_index do |name, index|
            @state_class.attribute(name, default: defaults[index] || default)
            after_initialize { fields[name] = Field.new(self, name) { state.send(name) } }
            define_method(name) { state.send(name) }
            yield @state_map, name, index
          end
        end

        def validate (&block)
          @state_class ||= Class.new(State::Base)
          @state_class.validate(&block)
        end

        def state_map
          @state_map || State::Map.new
        end
      end
    end
  end
end