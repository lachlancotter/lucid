module Lucid
  describe Message do
    context "valid data" do
      it "provides the data" do
        message_class = Class.new(Message) do
          validate do
            required(:foo).filled(:string)
          end
        end
        message = message_class.new(foo: "bar")
        expect(message.to_h).to eq({ foo: "bar" })
        expect(message.foo).to eq("bar")
      end
    end

    context "invalid data" do
      it "raises an exception" do
        message_class = Class.new(Message) do
          validate do
            required(:foo).filled(:string)
          end
        end
        expect { message_class.new(foo: nil) }.to raise_error(Message::Invalid)
      end
    end

    context "no schema" do
      it "does not raise an error" do
        message_class = Class.new(Message)
        expect { message_class.new(foo: "bar") }.not_to raise_error
      end
    end
  end
end