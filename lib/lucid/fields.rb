module Lucid
  module Fields
    def self.included(base)
      base.extend(ClassMethods)
    end

    class NoSuchField < ArgumentError
      def initialize (name, context)
        super("No such field: #{name} in #{context}")
      end
    end

    def fields
      @fields ||= {}
    end

    def field (name)
      raise NoSuchField.new(name, self) unless field?(name)
      fields[name]
    end

    def [] (name)
      field(name).value
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
      # name - The name of the field to be defined.
      # over - The name of the collection to be mapped over.
      # map_f - The block to be called for each element in the collection.
      #  The block can also define additional keyword arguments, treated as signal
      #  names, which will be passed to the block when it is called.
      # 
      def map (name, over:, &map_f)
        after_initialize do
          signal_block = proc do |**signal_kwargs|
            enumerable = fields[over].value
            map_kwargs = signal_kwargs.reject { |k, _| k == over }
            enumerable.each_with_index.map do |element, index|
              map_f.call(element, index, **map_kwargs)
            end if enumerable
          end
          exec         = Field::Execution.new(signal_block)
                                         .set_keywords(over, from_block: map_f)
          fields[name] = Field.new(self, exec)
        end
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