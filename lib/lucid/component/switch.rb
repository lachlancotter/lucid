require "checked"

module Lucid
  module Component
    #
    # A Switch is a factory for components of dynamic class.
    # It takes a key and a map of values to component classes.
    #
    class Switch
      include Checked

      def initialize (key, map)
        @key = check(key).symbol.value
        @map = check(map).hash.every_value { |v| v.type(Class) }.value
      end

      attr_reader :key

      def [] (key)
        @map[key]
      end

      def call (parent_component)
        component_class(parent_component)
      end

      def component_class (parent_component)
        check(parent_component).has_type(Component::Base)
        check(parent_component.state.to_h).has_key(@key)
        @map[parent_component.state[@key].to_sym].tap do |klass|
          check(klass).has_type(Class)
        end
      end
    end
  end
end