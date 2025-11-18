module Lucid
  #
  # Dispatch events to the component and handler.
  # 
  class MessageBus
    def initialize (handler, container)
      # @component = Types.component.optional[component]
      @handler   = Types.handler.optional[handler]
      @container = Types.container.optional[container]
      @published = []
    end

    attr_reader :published

    def dispatch (command)
      @handler.dispatch(command, @container) if @handler
    end

    def publish (event)
      @published << event
      @handler.publish(event, @container) if @handler
      # @component.apply(event) if @component
    end

    def to_s
      "<#{self.class.name} #{object_id}>"
    end

    def inspect
      to_s
    end
  end
end