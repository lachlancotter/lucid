require "checked"

module Lucid
  module Component
    #
    # A Switch is a factory for components of dynamic class.
    # It takes a key and a map of values to component classes.
    #
    class Match


      def initialize (key, map)
        @key = Check[key].symbol.value
        @map = Check[map].hash.every_value { |v| v.type(Class) }.value
      end

      attr_reader :key

      def [] (key)
        @map[key]
      end

      def call (parent_component)
        component_class(parent_component)
      end

      def component_class (parent_component)
        Check[parent_component].has_type(Component::Base)
        Check[parent_component.state.to_h].has_key(@key)
        @map[parent_component.state[@key].to_sym].tap do |klass|
          Check[klass].has_type(Class)
        end
      end
    end
  end
end