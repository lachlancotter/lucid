module Lucid
  describe Handler do

    describe "construction" do
      context "valid dependencies" do
        it "injects dependencies" do
          handler_class = Class.new(Handler) { prop :foo, Types.string }
          handler       = handler_class.new(nil, foo: "bar")
          expect(handler.foo).to eq("bar")
        end
      end

      context "invalid dependencies" do
        it "raises an exception" do
          handler_class = Class.new(Handler) { prop :foo, Types.string }
          expect { handler_class.new(nil) }.to raise_error(Handler::MissingDependency)
        end
      end
    end

    describe ".dispatch" do
      context "no handler" do
        it "raises an exception" do
          handler = Class.new(Handler)
          expect do
            handler.dispatch(Object.new)
          end.to raise_error(Handler::NoHandlerError)
        end
      end

      context "one handler" do
        it "performs the command" do
          called  = false
          handler = Class.new(Handler) do
            perform(Command) { |cmd| called = true }
          end
          handler.dispatch(Command.new)
          expect(called).to be(true)
        end
      end

      context "multiple handlers" do
        it "calls the first handler only" do
          call_count = 0
          handler    = Class.new(Handler) do
            perform(Command) { |cmd| call_count += 1 }
            perform(Command) { |cmd| call_count += 2 }
          end
          handler.dispatch(Command.new)
          expect(call_count).to eq(1)
        end
      end

      context "delegated handlers" do
        it "calls the delegates" do
          called   = false
          delegate = Class.new(Handler) { perform(Command) { |cmd| called = true } }
          handler  = Class.new(Handler) { recruit delegate }
          expect(delegate.performs?(Command)).to be_truthy
          expect(handler.performs?(Command)).to be_truthy
          handler.dispatch(Command.new)
          expect(called).to be(true)
        end
      end

      context "multiple calls" do
        it "isolates handler state" do
          result  = nil
          handler = Class.new(Handler) do
            perform(Command) do
              @count ||= 0
              @count += 1
              result = @count
            end
          end
          handler.dispatch(Command.new)
          handler.dispatch(Command.new)
          expect(result).to eq(1)
        end
      end
    end
  end
end