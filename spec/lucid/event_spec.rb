require "lucid/event_bus"

module Lucid
  describe Event do
    describe ".notify" do
      it "it passes an event to the bus" do
        app         = double("app")
        bus         = EventBus.new(app)
        event_class = Class.new(Event) do
          attribute :foo
        end
        expect(bus).to receive(:notify) do |event|
          expect(event).to be_a(event_class)
          expect(event.foo).to eq("bar")
        end
        Event.with_bus(bus) do
          event_class.notify(foo: "bar")
        end
      end
    end
  end
end