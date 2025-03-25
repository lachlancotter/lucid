module Lucid
  describe EventBroadcast do

    describe "subscriber registration" do
      context "one subscriber" do
        it "registers the subscriber" do
          event_class   = Class.new(Event)
          handler_class = Class.new(Handler) do
            subscribe(event_class) { |message| }
          end
          expect(handler_class.subscribes?(event_class)).to be_truthy
          expect(handler_class.subscribers_for(event_class).size).to eq(1)
        end
      end

      context "multiple subscribers" do
        it "registers the subscribers" do
          event_class   = Class.new(Event)
          handler_class = Class.new(Handler) do
            subscribe(event_class) { |message| }
            subscribe(event_class) { |message| }
          end
          expect(handler_class.subscribes?(event_class)).to be_truthy
          expect(handler_class.subscribers_for(event_class).size).to eq(2)
        end
      end

      context "nested subscribers" do
        it "registers the subscribers" do
          event_class   = Class.new(Event)
          nested_class  = Class.new do
            extend EventBroadcast
            subscribe(event_class) { |message| }
          end
          handler_class = Class.new do
            extend EventBroadcast
            recruit(nested_class)
          end
          expect(handler_class.subscribes?(event_class)).to be_truthy
          expect(handler_class.subscribers_for(event_class).size).to eq(1)
        end
      end
    end

    describe "publish" do
      context "no subscribers" do
        it "does nothing" do
          event_class   = Class.new(Event)
          handler_class = Class.new(Handler) do
          end
          expect { handler_class.publish(event_class.new, {}) }.not_to raise_error
        end
      end

      context "one subscriber" do
        it "calls the subscriber" do
          called          = false
          handler_context = nil
          event_class     = Class.new(Event)
          handler_class   = Class.new(Handler) do
            extend EventBroadcast
            subscribe(event_class) do
              called          = true
              handler_context = self
            end
          end
          handler_class.publish(event_class.new, {})
          expect(called).to be_truthy
          expect(handler_context).to be_instance_of(handler_class)
        end
      end

      context "multiple subscribers" do
        it "calls the subscribers in order" do
          calls         = []
          event_class   = Class.new(Event)
          handler_class = Class.new(Handler) do
            subscribe(event_class) { calls << "first" }
            subscribe(event_class) { calls << "second" }
          end
          handler_class.publish(event_class.new, {})
          expect(calls).to eq(%w[first second])
        end
      end

      context "nested subscribers" do
        it "calls the subscribers in order" do
          calls          = []
          event_class    = Class.new(Event)
          nested_handler = Class.new(Handler) do
            extend EventBroadcast
            subscribe(event_class) { calls << "first" }
          end
          handler_class  = Class.new(Handler) do
            extend EventBroadcast
            recruit(nested_handler)
            subscribe(event_class) { calls << "second" }
          end
          handler_class.publish(event_class.new, {})
          expect(calls).to eq(%w[second first])
        end
      end

      context "invalid message" do
        it "raises an exception" do
          event_class   = Class.new
          handler_class = Class.new(Handler) do
          end
          expect do
            handler_class.publish(event_class.new, {})
          end.to raise_error(EventBroadcast::InvalidEvent)
        end
      end
    end

  end
end