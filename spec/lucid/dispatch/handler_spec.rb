module Lucid
  describe Handler do

    describe "#call" do
      it "handles errors" do
        message_class = Class.new(Command)
        handler_class = Class.new(Handler) { perform(message_class) { raise StandardError } }
        block         = handler_class.handlers[message_class]

        message_bus = MessageBus.new(nil, nil, nil)
        container   = { message_bus: message_bus, session: nil }
        handler     = handler_class.new(message_class.new, container, &block)
        expect(message_bus).to receive(:publish) do |event|
          expect(event).to be_a(HandlerRaised)
          expect(event.error).to be_a(StandardError)
        end
        expect { handler.call }.not_to raise_error
      end
    end

    describe ".adopt" do
      context "default policy" do
        it "always calls" do
          called        = false
          message_class = Class.new(Command)
          container     = { message_bus: nil, session: nil }
          handler       = Handler.new(message_class.new, container) { called = true }
          handler.call
          expect(called).to eq(true)
        end
      end

      context "policy permits message" do
        it "calls the handler" do
          called        = false
          message_class = Class.new(Command)
          policy_class  = Class.new(Policy) do
            def permits_message? (message)
              true
            end
          end
          handler_class = Class.new(Handler) { adopt(policy_class) }
          container     = { message_bus: nil, session: nil }
          handler       = handler_class.new(message_class.new, container) { called = true }
          handler.call
          expect(called).to eq(true)
        end
      end

      context "policy denies message" do
        it "does not call the handler" do
          called        = false
          message_class = Class.new(Command)
          policy_class  = Class.new(Policy) do
            def permits_message? (message)
              false
            end
          end
          handler_class = Class.new(Handler) { adopt(policy_class) }
          message_bus = MessageBus.new(nil, nil, nil)
          container   = { message_bus: message_bus, session: nil }
          handler       = handler_class.new(message_class.new, container) { called = true }
          handler.call
          expect(called).to eq(false)
        end
      end
    end

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