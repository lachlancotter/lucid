module Lucid
  describe Component::Eventing do
    describe ".on" do
      context "event class" do
        it "calls the block when an event matches" do
          result          = nil
          event_class     = Class.new(Event)
          component_class = Class.new(Component::Base) do
            on(event_class) do |event|
              result = self
            end
          end
          component       = component_class.new({})
          event           = event_class.new
          component.notify(event)
          expect(result).to be(component)
        end
      end

      context "event filter" do
        it "calls the block when the constraints are met" do
          result          = nil
          event_class     = Class.new(Event)
          component_class = Class.new(Component::Base) do
            on(event_class[foo: "bar"]) do |event|
              result = event
            end
          end
          component       = component_class.new({})
          event           = event_class.new(foo: "bar")
          component.notify(event)
          expect(result).to be(event)
        end

        it "doesn't call the block when the constraint is not met" do
          result          = nil
          event_class     = Class.new(Event)
          component_class = Class.new(Component::Base) do
            on(event_class[foo: "bar"]) do |event|
              result = event
            end
          end
          component       = component_class.new({})
          event           = event_class.new(foo: "baz")
          component.notify(event)
          expect(result).to be_nil
        end
      end
      
    end
  end
end