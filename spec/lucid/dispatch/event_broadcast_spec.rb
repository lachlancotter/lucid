module Lucid
  describe EventBroadcast do

    describe "subscriber registration" do
      context "one subscriber" do
        it "registers the subscriber" do
          message_class = Class.new(Event)
          broadcaster   = Class.new do
            extend EventBroadcast
            subscribe(message_class) { |message| }
          end
          expect(broadcaster.subscribes?(message_class)).to be_truthy
          expect(broadcaster.subscribers_for(message_class).size).to eq(1)
        end
      end

      context "multiple subscribers" do
        it "registers the subscribers" do
          message_class = Class.new(Event)
          broadcaster   = Class.new do
            extend EventBroadcast
            subscribe(message_class) { |message| }
            subscribe(message_class) { |message| }
          end
          expect(broadcaster.subscribes?(message_class)).to be_truthy
          expect(broadcaster.subscribers_for(message_class).size).to eq(2)
        end
      end

      context "nested subscribers" do
        it "registers the subscribers" do
          message_class = Class.new(Event)
          nested_class  = Class.new do
            extend EventBroadcast
            subscribe(message_class) { |message| }
          end
          broadcaster   = Class.new do
            extend EventBroadcast
            recruit(nested_class)
          end
          expect(broadcaster.subscribes?(message_class)).to be_truthy
          expect(broadcaster.subscribers_for(message_class).size).to eq(1)
        end
      end
    end

    describe "subscriber lookup" do

    end

  end
end