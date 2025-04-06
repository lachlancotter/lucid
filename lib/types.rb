require "dry/types"

module Types
  include Dry.Types()

  # Primitive types

  %i[string integer float bool date time datetime hash symbol].each do |name|
    define_singleton_method(name) { Params.const_get(name.capitalize) }
  end

  def self.array (type = Types::Any)
    Types::Array.of(type)
  end
  
  def self.any
    Types::Any
  end
  
  def self.enumerable
    instance(Enumerable)
  end
  
  def self.callable
    Types::Callable
  end

  def self.instance (type)
    Instance(type)
  end

  def self.subclass(type)
    Types::Class.constrained(lteq: type)
  end

  def self.union (a, b)
    Types.instance(a) | Types.instance(b)
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
    union(Lucid::State::HashReader, Lucid::State::Reader)
  end
end