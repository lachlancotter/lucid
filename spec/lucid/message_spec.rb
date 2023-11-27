module Lucid
  describe Message do
    context "valid message" do
      it "has no errors" do
        message_class = Class.new(Message) do
          validate do
            required(:foo)
          end
        end
        message = message_class.new(foo: "bar")
        expect(message).to be_valid
        expect(message.errors).to be_empty
      end
    end

    context "invalid message" do
      it "has errors" do
        message_class = Class.new(Message) do
          validate do
            required(:foo)
          end
        end
        message = message_class.new
        expect(message).to_not be_valid
        expect(message.errors[:foo]).to eq(["is missing"])
      end
    end
  end
end