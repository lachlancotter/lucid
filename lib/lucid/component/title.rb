module Lucid
  module Component
    module Title
      def self.included (base)
        base.extend(ClassMethods)
        base.title { "Untitled" }
      end
      
      def nested_title
        nested_route_component.title
      end

      module ClassMethods
        def title (&block)
          let(:title, &block)
        end
      end
    end
  end
end