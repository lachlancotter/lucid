require "lucid/event_bus"

module Lucid
  describe EventBus do
    describe ".notify" do
      it "calls registered event handlers" do
        event_class = Class.new(Event) do
          params do
            attribute :foo
          end
        end
        app         = Class.new(View) do
          state do
            attribute :foo
          end
          on event_class do |event, state|
            puts "called"
            state[:foo] = event.data.foo
          end
        end.new
        bus         = EventBus.new(app)
        bus.notify(event_class.new(foo: "bar"))
        expect(app.state[:foo]).to eq("bar")
      end
    end
  end
end