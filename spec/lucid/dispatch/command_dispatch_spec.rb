module Lucid
  describe CommandDispatch do
    describe "construction" do
      context "valid dependencies" do
        it "injects dependencies" do
          handler_class = Class.new(Handler) { prop :foo, Types.string }
          handler       = handler_class.new(foo: "bar") {}
          expect(handler.foo).to eq("bar")
        end
      end

      context "invalid dependencies" do
        it "raises an exception" do
          handler_class = Class.new(Handler) { prop :foo, Types.string }
          expect { handler_class.new({}) }.to raise_error(Handler::MissingDependency)
        end
      end
    end
  end

  describe "handler registration" do
    context "one handler" do
      it "registers the handler" do
        message_class = Class.new(Command)
        expect {
          handler_class = Class.new(Handler) do
            perform(message_class) { |message| }
          end
          expect(handler_class.performs?(message_class)).to be_truthy
        }.not_to raise_error
      end
    end

    context "ambiguous dispatch" do
      it "raises an exception" do
        message_class = Class.new(Command)
        expect {
          handler_class = Class.new(Handler) do
            perform(message_class) { |message| }
            perform(message_class) { |message| }
          end
        }.to raise_error(CommandDispatch::AmbiguousDispatch)
      end
    end

    context "ambiguous nested dispatch" do
      it "raises an exception" do
        message_class = Class.new(Command)
        expect {
          nested_handler_class = Class.new(Handler) do
            perform(message_class) { |message| }
          end
          handler_class        = Class.new(Handler) do
            perform(message_class) { |message| }
            recruit(nested_handler_class)
          end
        }.to raise_error(CommandDispatch::AmbiguousDispatch)
      end
    end
  end

  context "handler lookup" do
    context "no handler" do
      it "raises an exception" do
        message_class = Class.new(Command)
        handler_class = Class.new(Handler)
        expect {
          handler_class.find_handler(message_class)
        }.to raise_error(CommandDispatch::NoHandler)
      end
    end

    context "direct handler" do
      it "returns the handler" do
        message_class = Class.new(Command)
        handler_class = Class.new(Handler) { perform(message_class) {} }
        called        = false
        handler_class.find_handler(message_class) do |klass, block|
          called = true
          expect(klass).to eq(handler_class)
          expect(block).to eq(handler_class.handlers[message_class])
        end
        expect(called).to be_truthy
      end
    end

    context "nested handler" do
      it "returns the nested handler" do
        message_class        = Class.new(Command)
        nested_handler_class = Class.new(Handler) { perform(message_class) {} }
        handler_class        = Class.new(Handler) { recruit(nested_handler_class) }
        called               = false
        handler_class.find_handler(message_class) do |klass, handler|
          called = true
          expect(klass).to eq(nested_handler_class)
          expect(handler).to eq(nested_handler_class.handlers[message_class])
        end
        expect(called).to be_truthy
      end
    end
  end

  describe ".dispatch" do
    context "registered message" do
      it "calls the message handler" do
        dispatched_message = nil
        message_class = Class.new(Command)
        handler_class = Class.new(Handler) do
          perform(message_class) do |message|
            dispatched_message = message
          end
        end
        context = {}
        handler_class.dispatch(message_class.new, context)
        expect(dispatched_message).to be_instance_of(message_class)
      end
    end

    context "registered in nested handler" do
      it "calls the message handler" do
        dispatched_message = nil
        called_handler = nil
        message_class = Class.new(Command)
        nested_handler_class = Class.new(Handler) do
          perform(message_class) do |message|
            dispatched_message = message
            called_handler = self
          end
        end
        handler_class = Class.new(Handler) { recruit(nested_handler_class) }
        context = {}
        handler_class.dispatch(message_class.new, context)
        expect(dispatched_message).to be_instance_of(message_class)
        expect(called_handler).to be_instance_of(nested_handler_class)
      end
    end

    context "unregistered message" do
      it "raises an exception" do
        message_class = Class.new(Command)
        handler_class = Class.new(Handler)
        expect { handler_class.dispatch(message_class.new) }.to raise_error(CommandDispatch::NoHandler)
      end
    end
  end

end