module Lucid
  describe Handler do

    describe ".let" do
      it "defines values" do
        handler_class = Class.new(Handler) { let(:foo) { "bar" } }
        message_class = Class.new(Command)
        container     = { message_bus: nil, session: nil }
        message       = message_class.new
        handler       = handler_class.new(message, container) {}
        expect(handler.foo).to eq("bar")
      end

      it "accepts a message argument" do
        handler_class = Class.new(Handler) { let(:foo) { |msg| msg[:count] } }
        message_class = Class.new(Command) { validate { optional(:count) } }
        container     = { message_bus: nil, session: nil }
        message       = message_class.new(count: 42)
        handler       = handler_class.new(message, container) {}
        expect(handler.foo).to eq(42)
      end

      it "memos the result" do
        count         = 0
        handler_class = Class.new(Handler) { let(:foo) { count += 1 } }
        message_class = Class.new(Command) {}
        container     = { message_bus: nil, session: nil }
        message       = message_class.new
        handler       = handler_class.new(message, container) {}
        expect(handler.foo).to eq(1)
        expect(handler.foo).to eq(1)
        expect(count).to eq(1)
      end
    end

  end
end