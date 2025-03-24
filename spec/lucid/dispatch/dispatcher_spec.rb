module Lucid

  describe ".dispatch" do
    context "no handler" do
      it "raises an error" do
        config        = Class.new(Handler)
        message_class = Class.new(Command)
        dispatcher    = Dispatcher.new(config)
        expect {
          dispatcher.dispatch(message_class.new)
        }.to raise_error(CommandDispatch::NoHandler)
      end
    end

    context "one handler" do
      it "calls the handler" do
        called        = false
        message_class = Class.new(Command)
        config        = Class.new(Handler) do
          perform message_class do |message|
            called = true
          end
        end
        dispatcher    = Dispatcher.new(config)
        dispatcher.dispatch(message_class.new)
        expect(called).to be_truthy
      end
    end

    context "multiple calls" do
      it "isolates handler state" do
        result     = nil
        handler    = Class.new(Handler) do
          perform(Command) do
            @count ||= 0
            @count += 1
            result = @count
          end
        end
        dispatcher = Dispatcher.new(handler)
        dispatcher.dispatch(Command.new)
        dispatcher.dispatch(Command.new)
        expect(result).to eq(1)
      end
    end
  end
end