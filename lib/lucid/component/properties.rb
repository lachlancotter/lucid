require "dry-struct"

module Lucid
  module Component
    #
    # Define and configure properties for a component.
    #
    module Properties
      def self.included(base)
        base.extend(ClassMethods)
      end

      attr_reader :props

      def initialize_props (props_hash)
        @props = self.class.props_class.new(
           Hash[
              Types.hash[props_hash].select do |key, value|
                self.class.props_class.schema.key?(key)
              end.map do |key, value|
                [key, normalise_prop(key, value)]
              end
           ]
        )
      rescue Dry::Struct::Error => e
        raise ConfigError.new(self, props_hash, e.message)
      end

      def normalise_prop (key, value)
        return value if value.is_a?(Field)
        if self.class.props_class.schema.key(key).try(value).success?
          value
        else
          Field.new(self) { value }
        end
      end

      # Called internally by the change tracking system. You typically should
      # not call this directly.
      # Maybe this can be removed because changes can be propagated through
      # signal props and don't have to be manually updated.
      def update_props (changed_props)
        @props = @props.new(changed_props)
        changed_props.keys.each { |key| field(key).invalidate if field?(key) }
      rescue Dry::Struct::Error => e
        raise ConfigError.new(self, changed_props, e.message)
      end

      private

      module ClassMethods
        # Define a signal property, passed by reference.
        def prop(name, type = Types.string.default("".freeze))
          # The default field returns the default value of the type.
          type       = Types.normalize(type)
          field_type = if type.default?
            Types.instance(Field).default { Field.new(self) { type[] } }
          else
            Types.instance(Field)
          end
          props_class.attribute(name, field_type)
          after_initialize { fields[name] = props[name] }
          define_method(name) do
            type[fields[name].value]
          rescue Dry::Types::CoercionError => e
            raise ConfigError.new(self, { name => fields[name].value }, e.message)
          end
        end

        # Define a value property, passed by value. Used internally by the framework.
        def static (name, type = Types.string)
          props_class.attribute(name, Types.normalize(type))
          after_initialize { fields[name] = Field.new(self) { props[name] } }
          define_method(name) { fields[name].value }
        end

        def props_class
          @props_class ||= if superclass.respond_to?(:props_class)
            Class.new(superclass.props_class)
          else
            Class.new(Dry::Struct)
          end
        end
      end
    end
  end
end