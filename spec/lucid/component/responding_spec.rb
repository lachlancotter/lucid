module Lucid
  describe Component::Responding do
    describe ".event_handler" do
      context "no handler" do
        it "returns nil" do
          event_class     = Class.new(Event)
          component_class = Class.new(Component::Base) {}
          expect(component_class.event_handler(event_class)).to be_nil
        end
      end

      context "class handler" do
        it "returns the handler" do
          event_class     = Class.new(Event)
          component_class = Class.new(Component::Base) do
            on(event_class) {}
          end
          expect(component_class.event_handler(event_class)).to be_a(Proc)
        end
      end

      context "superclass handler" do
        it "returns the handler" do
          event_superclass = Class.new(Event)
          event_class      = Class.new(event_superclass)
          component_class  = Class.new(Component::Base) do
            on(event_superclass) {}
          end
          expect(component_class.event_handler(event_class)).to be_a(Proc)
        end
      end
    end
  end
end