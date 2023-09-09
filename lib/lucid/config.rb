module Lucid
  #
  # Stores configuration options for a view or action. Provides
  # access to the options via method calls as well as standard
  # hash access.
  #
  class Config < Hash
    def initialize (hash)
      super()
      hash.each do |key, value|
        self[key] = value
      end
    end

    private

    def method_missing(symbol, *args)
      if has_key?(symbol.to_sym)
        self[symbol.to_sym]
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      self.has_key?(method_name) || super
    end
  end
end