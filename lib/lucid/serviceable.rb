module Lucid
  module Serviceable
    def self.included (base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def store (name, store_class = nil, &block)
        define_method(name) do
          @stores       ||= {}
          @stores[name] ||= store_class.new
        end
      end
    end
  end
end