require "lucid/event_bus"

module Lucid
  describe Event do
    describe ".notify" do
      it "it passes an event to the bus" do
        app         = double("app")
        bus         = EventBus.new(app)
        Event.bus   = bus
        event_class = Class.new(Event) do
          params do
            attribute :foo
          end
        end
        expect(bus).to receive(:notify) do |event|
          expect(event).to be_a(event_class)
          expect(event.data.foo).to eq("bar")
        end
        event_class.notify(foo: "bar")
      end
    end
  end
end