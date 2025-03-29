module Lucid
  module Fields
    def self.included(base)
      base.extend(ClassMethods)
    end

    class NoSuchField < ArgumentError
      def initialize (name, path)
        super("No such field: #{name} in #{path}")
      end
    end

    def fields
      @fields ||= {}
    end

    def field (name)
      raise NoSuchField.new(name, props.path) unless field?(name)
      fields[name]
    end

    def field? (name)
      fields.key?(name)
    end

    def watch (*keys, &block)
      keys.each { |key| field(key).attach(self, &block) }
    end

    def invalidate (*keys)
      keys.each { |key| field(key).invalidate }
    end

    module ClassMethods
      #
      # Define a dependent field that is calculated from the specified
      # dependent values. The block is evaluated in the context of the
      # component instance.
      #
      def let (name, &block)
        after_initialize { fields[name] = Field.new(self, &block) }
        define_method(name) { fields[name].value }
      end

      #
      # Run an arbitrary block of code when a field changes.
      #
      def watch (*keys, &block)
        after_initialize { watch(*keys) { instance_exec(&block) } }
      end
    end

  end
end