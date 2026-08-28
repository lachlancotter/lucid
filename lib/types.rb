require "dry/types"

module Types
  include Dry.Types()

  UNDEFINED = Object.new.freeze

  # Primitive types

  PARAM_TYPES = {
    string: "String",
    float: "Float",
    bool: "Bool",
    date: "Date",
    time: "Time",
    datetime: "DateTime",
    hash: "Hash",
    symbol: "Symbol"
  }.freeze

  NAMED_TYPES = (PARAM_TYPES.keys + [:any, :integer, :array]).freeze

  PARAM_TYPES.each do |name, constant|
    define_singleton_method(name) { Params.const_get(constant) }
  end

  def self.integer
    # Coerce strings to integers where possible.
    Params::Integer.constructor do |value|
      case value
      when String then Integer(value) rescue nil
      when Integer then value
      else nil
      end
    end
  end

  def self.array (type = Types::Any)
    Types::Array.of(resolve(type))
  end

  def self.any
    Types::Any
  end

  def self.enumerable
    instance(Enumerable)
  end

  def self.callable
    instance(Proc)
  end

  def self.instance (type)
    Instance(type)
  end

  def self.optional (type)
    resolve(type).optional
  end

  def self.enum (*values)
    Types::Any.enum(*values)
  end

  # Convert a type expression to a dry type.

  def self.normalize (type)
    resolve(type)
  end

  def self.resolve (type, optional: false, default: UNDEFINED)
    resolved = case type
    when Dry::Types::Type then type
    when Symbol then named(type)
    when Class then class_type(type)
    else unsupported(type)
    end

    resolved = resolved.optional if optional
    resolved = resolved.default(default) unless default.equal?(UNDEFINED)
    resolved
  end

  def self.named (name)
    return any if name == :any
    return integer if name == :integer
    return public_send(name) if NAMED_TYPES.include?(name)

    raise ArgumentError, "Unknown type: #{name.inspect}"
  end

  def self.class_type (klass)
    case klass.name
    when "String" then string
    when "Integer" then integer
    when "Float" then float
    when "TrueClass", "FalseClass" then bool
    when "Hash" then hash
    when "Symbol" then symbol
    when "Array" then array
    else instance(klass)
    end
  end

  def self.unsupported (type)
    raise ArgumentError, "Invalid type: #{type.inspect}"
  end

  def self.call (type, **options)
    resolve(type, **options)
  end

  def self.subclass(type)
    Types::Class.constrained(lteq: type)
  end

  def self.union (*types)
    types.map { |type| resolve(type) }.reduce(:|)
  end

  # Lucid types....

  def self.http_message
    Types.instance(Lucid::HTTP::Message)
  end

  def self.component
    Types.instance(Lucid::Component::Base)
  end

  def self.collection
    Types.instance(Lucid::Component::Nesting::Collection)
  end

  def self.handler
    Types.subclass(Lucid::Handler)
  end

  def self.container
    Types.instance(Lucid::App::Container)
  end

  def self.reader
    Types.instance(Lucid::State::Store) |
       Types.instance(Lucid::State::Scope) |
       Types.instance(Lucid::State::HashStore)
       # Types.instance(Lucid::State::HashStore::Cursor)
    # union(Lucid::State::HashStore::Cursor, Lucid::State::Cursor)
  end
end

module Lucid
  Types = ::Types unless const_defined?(:Types, false)
end
