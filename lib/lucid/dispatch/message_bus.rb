module Lucid
  #
  # Dispatch events to the component and handler.
  # 
  class MessageBus
    def initialize (component, handler, container)
      @component = Types.component.optional[component]
      @handler   = Types.handler.optional[handler]
      @container = Types.container.optional[container]
    end

    def dispatch (command)
      @handler.dispatch(command, @container) if @handler
    end

    def publish (event)
      @handler.publish(event, @container) if @handler
      @component.apply(event) if @component
    end

    def to_s
      "<#{self.class.name} #{object_id}>"
    end

    def inspect
      to_s
    end
  end
end