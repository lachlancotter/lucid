require "dry/types"

module Types
  include Dry.Types()

  %i[string integer float bool date time datetime array hash symbol].each do |name|
    define_singleton_method(name) { Params.const_get(name.capitalize) }
  end

  def self.subclass(type)
    Types::Class.constrained(lt: type)
  end
end