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

      context "nested component handler" do
        it "runs handlers in nested components" do
          result                 = nil
          event_class            = Class.new(Event)
          component_class        = Class.new(Component::Base) do
            on(event_class) do |event|
              result = self
            end
          end
          parent_component_class = Class.new(Component::Base) do
            nest(:nested) { component_class }
          end
          component              = parent_component_class.new({}, event_class.new)
          expect(result).to be(component.nested)
        end
      end

      context "nested collection element handler" do
        it "runs handlers in matching elements" do
          result                 = nil
          event_class            = Class.new(Event)
          component_class        = Class.new(Component::Base) do
            prop :index, Types.integer
            on(event_class) { |event| result = self }
          end
          parent_component_class = Class.new(Component::Base) do
            let(:collection) { [1, 2, 3] }
            nest(:nested) do
              component_class[]
                 .enum(:collection, as: :index)
                 .for(event_class) { 1 }
            end
          end
          component              = parent_component_class.new({}, event_class.new)
          expect(result).to be(component.nested[0])
        end
      end

      context "multiple events" do
        context "root component" do
          it "runs all matching handlers" do
            event1_class    = Class.new(Event)
            event2_class    = Class.new(Event)
            component_class = Class.new(Component::Base) do
              param :count, Types.integer.default(0)
              on(event1_class) { update count: count + 1 }
              on(event2_class) { update count: count + 2 }
            end
            component       = component_class.new({}, event1_class.new, event2_class.new)
            expect(component.count).to eq(3)
          end
        end

        context "child component" do
          it "runs all matching handlers" do
            event1_class          = Class.new(Event)
            event2_class          = Class.new(Event)
            child_component_class = Class.new(Component::Base) do
              param :count, Types.integer.default(0)
              on(event1_class) { update count: count + 1 }
              on(event2_class) { update count: count + 2 }
            end
            component_class       = Class.new(Component::Base) do
              nest(:child) { child_component_class }
            end
            component             = component_class.new({}, event1_class.new, event2_class.new)
            expect(component.child.count).to eq(3)
          end
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

      context "link class" do
        it "raises an exception" do
          link_class = Class.new(Link)
          expect {
            Class.new(Component::Base) do
              on(link_class) { 1 }
            end
          }.to raise_error(ApplicationError)
        end
      end

    end
  end
end