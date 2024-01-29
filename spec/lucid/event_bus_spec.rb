require "lucid/event_bus"

module Lucid
  describe EventBus do
    # describe ".notify" do
    #   it "calls registered event handlers" do
    #     event_class = Class.new(Event) do
    #       attribute :foo
    #     end
    #     app         = Class.new(Component::Base) do
    #       state do
    #         attribute :foo
    #       end
    #       on event_class do |event, state|
    #         puts "called"
    #         state[:foo] = event.foo
    #       end
    #     end.new
    #     bus         = EventBus.new(app)
    #     bus.notify(event_class.new(foo: "bar"))
    #     expect(app.state[:foo]).to eq("bar")
    #   end
    # end
  end
end