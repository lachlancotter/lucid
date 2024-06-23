module Lucid
  describe Commandable do
    describe "#dispatch" do
      context "no handler" do
        it "raises an exception" do
          bus = Class.new do
            include Commandable
          end.new
          expect do
            bus.dispatch(Object.new)
          end.to raise_error(Commandable::NoHandlerError)
        end
      end

      context "one handler" do
        it "performs the command" do
          called = false
          bus = Class.new do
            include Commandable
            perform(Command) { |cmd| called = true }
          end.new
          bus.dispatch(Command.new)
          expect(called).to be(true)
        end
      end

      context "multiple handlers" do
        it "calls the first handler only" do
          call_count = 0
          bus = Class.new do
            include Commandable
            perform(Command) { |cmd| call_count += 1 }
            perform(Command) { |cmd| call_count += 2 }
          end.new
          bus.dispatch(Command.new)
          expect(call_count).to eq(1)
        end
      end
    end
  end
end