require "dry-schema"
require "immutable/hash"

module Lucid
  module State
    class Invalid < StandardError
      def initialize(state)
        super(
           <<~MSG
             Invalid state: 
              #{state.errors.to_h}
              ---
              #{state.to_h}
           MSG
        )
      end
    end

    #
    # Encapsulates the application state.
    #
    class Base
      extend Forwardable

      def initialize(data = {})
        @data = validated(
           self.class.map_attributes do |attr|
             attr.build(data)
           end
        )
        raise Invalid, self unless valid?
      end

      def_delegators :@data, :[], :keys, :key?, :to_h

      def validated (data)
        if schema
          schema.call(data).to_h
        else
          data
        end
      end

      def == (other)
        if other.is_a?(Hash)
          to_h.eql?(other)
        else
          super(other)
        end
      end

      def inspect
        "<State #{to_h}>"
      end

      def valid?
        schema ? schema.call(to_h).success? : true
      end

      def errors
        schema.call(to_h).errors
      end

      def empty?
        @data.empty?
      end

      def schema
        self.class.schema
      end

      #
      # Merges the new data into the state, modifying this object.
      #
      def update (data)
        @data = validated(@data.merge(data))
      end

      # ===================================================== #
      #    Class Methods
      # ===================================================== #

      class << self
        #
        # Define an attribute.
        #
        def attribute (name, default: nil, &constructor)
          attributes[name] = Attribute.new(name, default: default, &constructor)
          define_method(name) { self[name] }
        end

        #
        # Returns a Hash of attributes defined on this class, including
        # attributes inherited from superclasses.
        #
        def attributes
          @attributes ||= Match.on(superclass) do
            responds_to(:attributes) { |sc| sc.attributes.dup }
            default { {} }
          end
        end

        #
        # Yield each attribute to the block and return a new hash
        # mapping attribute names to block results.
        #
        def map_attributes (&block)
          attributes.map { |name, attr| [name, block.call(attr)] }.to_h
        end

        # def build_attributes (&block)
        #   new(map_attributes(&block))
        # end

        #
        # Define validation rules.
        #
        def validate (&block)
          @schema = Dry::Schema.Params(&block)
        end

        attr_reader :schema
      end

      #
      # Define an attribute with a name, default value and constructor.
      #
      class Attribute
        def initialize (name, default: nil, &constructor)
          @name        = name
          @default     = default
          @constructor = constructor
        end

        #
        # Return constructor results for the attribute value in
        # the given hash, or the default value if the hash does
        # not contain the attribute.
        #
        def build (hash, context: nil)
          Match.on(@constructor) do
            type(NilClass) { value_in(hash) }
            # We might want to run constructor blocks in the context of the encompassing
            # component. This would allow the constructor to access the component context.
            # But would require a way to pass that context through to the builder.
            # Not sure if this is necessary yet.
            # default { context.instance_exec(value_in(hash), &@constructor) }
            default { @constructor.call(value_in(hash)) }
          end
        end

        def value_in (hash)
          hash.key?(@name) ? hash[@name] : @default
        end
      end

    end
  end
end