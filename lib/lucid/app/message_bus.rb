module Lucid
  #
  # Dispatch events to the component and handler.
  # 
  class MessageBus
    def initialize (component, handler, container)
      @component = Types.component[component]
      @handler   = Types.handler[handler]
      @container = Types.container[container]
    end

    def dispatch (command)
      @handler.dispatch(command, @container)
    end

    def publish (event)
      @handler.publish(event, @container)
      @component.notify(event)
    end

    def to_s
      "<#{self.class.name} #{object_id}>"
    end

    def inspect
      to_s
    end
  end
end