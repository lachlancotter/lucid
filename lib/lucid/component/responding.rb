module Lucid
  module Component
    #
    # Register event handlers that respond to notifications.
    #
    module Responding
      def self.included (base)
        base.extend(ClassMethods)
      end
      
      def notify (event)
        self.class.responders.notify(event, self)
        each_subcomponent { |sub| sub.notify(event) }
      end

      private

      module ClassMethods
        def on (event_type, *keys, **maps, &block)
          responders.register(event_type, *keys, **maps, &block)
        end

        def responders
          @responders ||= Responders.new
        end
      end
    end
  end
end