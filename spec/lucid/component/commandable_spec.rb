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
            perform Object do |command|
              called = true
            end
          end.new
          bus.dispatch(Object.new)
          expect(called).to be(true)
        end
      end

      context "multiple handlers" do
        it "calls the first handler only" do
          call_count = 0
          bus = Class.new do
            include Commandable
            perform Object do |command|
              call_count += 1
            end
            perform Object do |command|
              call_count += 1
            end
          end.new
          bus.dispatch(Object.new)
          expect(call_count).to eq(1)
        end
      end
    end
  end
end