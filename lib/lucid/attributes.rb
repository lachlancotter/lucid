module Lucid
  #
  # A class with attributes.
  #
  module Attributes
    def self.included(base)
      base.extend(ClassMethods)
    end

    # def init_attributes (data)
    #   Check[data].hash
    #   @attributes = self.class.map_attributes do |attr|
    #     attr.build(data, context: self)
    #   end
    # end

    def [](key)
      @attributes[key]
    end

    module ClassMethods
      def attribute (name, type = Types.string)
        state_class.attribute(name, type)
        # attributes[name] = Def.new(name, type)
        after_initialize { fields[name] = Field.new(self) { self[name] } }
        define_method(name) { self[name] }
      end

      def state_class
        @state_class ||= Class.new(Dry::Struct)
      end

      # def attributes
      #   @attributes ||= Match.on(superclass) do
      #     responds_to(:attributes) { |sc| sc.attributes.dup }
      #     default { {} }
      #   end
      # end

      # def map_attributes (&block)
      #   attributes.map { |name, attr| [name, block.call(attr)] }.to_h
      # end
    end

    # class Def
    #   def initialize (name, type)
    #     @name = Types.symbol[name]
    #     @type = type
    #   end
    #
    #   #
    #   # Return constructor results for the attribute value in
    #   # the given hash, or the default value if the hash does
    #   # not contain the attribute.
    #   #
    #   def build (hash, context: nil)
    #     @type[hash.fetch(@name) { Dry::Types::Undefined }]
    #     # Match.on(@type.constructor) do
    #     #   type(NilClass) { value_in(hash) }
    #     #   # We might want to run constructor blocks in the context of the encompassing
    #     #   # component. This would allow the constructor to access the component context.
    #     #   # But would require a way to pass that context through to the builder.
    #     #   # Not sure if this is necessary yet.
    #     #   # default { context.instance_exec(value_in(hash), &@constructor) }
    #     #   default { @type[value_in(hash)] }
    #     # end
    #   end
    # end

  end
end