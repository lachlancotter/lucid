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
          component       = component_class.new({}, event_class.new)
          expect(result).to be(component)
        end
      end

      context "event subclass" do
        it "calls the block when an event matches" do
          result           = nil
          event_superclass = Class.new(Event)
          event_class      = Class.new(event_superclass)
          component_class  = Class.new(Component::Base) do
            on(event_superclass) do |event|
              result = self
            end
          end
          component        = component_class.new({}, event_class.new)
          expect(result).to be(component)
        end
      end

      context "event filter" do
        context "key match" do
          it "calls the block when the values match" do
            result          = nil
            event_class     = Class.new(Event)
            component_class = Class.new(Component::Base) do
              let(:foo) { "bar" }
              on(event_class[:foo]) do |event|
                result = event
              end
            end
            event           = event_class.new(foo: "bar")
            component       = component_class.new({}, event)
            expect(result).to be(event)
          end

          it "doesn't call the block when the values don't match" do
            result          = nil
            event_class     = Class.new(Event)
            component_class = Class.new(Component::Base) do
              let(:foo) { "bar" }
              on(event_class[:foo]) do |event|
                result = event
              end
            end
            event           = event_class.new(foo: "baz")
            component       = component_class.new({}, event)
            expect(result).to be_nil
          end
        end

        context "literal match" do
          it "calls the block when the constraints are met" do
            result          = nil
            event_class     = Class.new(Event)
            component_class = Class.new(Component::Base) do
              on(event_class[foo: "bar"]) do |event|
                result = event
              end
            end
            event           = event_class.new(foo: "bar")
            component       = component_class.new({}, event)
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
            event           = event_class.new(foo: "baz")
            component       = component_class.new({}, event)
            expect(result).to be_nil
          end
        end
      end

    end
  end
end