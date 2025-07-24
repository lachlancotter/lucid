module Lucid
  class App
    describe Container do
      it "provides the request" do
        env       = {}
        container = Container.new({}, env)
        request   = container[:request]
        expect(request).to be_a(HTTP::RequestAdaptor)
      end

      it "builds the component" do
        component_class = Class.new(Lucid::Component::Base) {}
        config          = { component_class: component_class }
        container       = Container.new(config, {})
        component       = container[:component]
        expect(component).to be_a(component_class)
      end

      it "wires up the message bus to the view" do
        handler_called  = false
        event_class     = Class.new(Lucid::Event)
        component_class = Class.new(Lucid::Component::Base) do
          on event_class do
            handler_called = true
          end
        end
        config          = { component_class: component_class }
        container       = Container.new(config, {})
        message_bus     = container[:message_bus]
        message_bus.publish(event_class.new)
        expect(handler_called).to eq(true)
      end
    end
  end
end