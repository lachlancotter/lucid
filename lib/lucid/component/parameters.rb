module Lucid
  module Component
    module Parameters

      def self.included (base)
        base.extend(ClassMethods)
      end

      module ClassMethods

      end

    end
  end
end