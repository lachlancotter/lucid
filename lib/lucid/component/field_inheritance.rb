module Lucid
  module Component
    #
    # Allow components to access fields declared in parent components and in the session.
    #
    module FieldInheritance
      def self.included(base)
        base.extend(ClassMethods)
      end

      #
      # Return the nearest ancestor component that defines the specified field.
      #
      def field_in_ancestor (name)
        raise Fields::NoSuchField.new(name, path) if props.parent.nil?
        return props.parent.field(name) if props.parent.field?(name)
        props.parent.field_in_ancestor(name)
      end

      module ClassMethods
        #
        # Declare a dependency on a field defined in a parent component.
        #
        def use (name, from: nil)
          after_initialize do
            fields[name] = case from
            when NilClass then field_in_ancestor(name)
            when :session then props.session.field(name)
            else raise ArgumentError, "Invalid field source: #{from}"
            end
          end
          define_method(name) { fields[name].value }
        end
      end
    end
  end
end