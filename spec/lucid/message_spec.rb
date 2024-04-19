module Lucid
  describe Message do
    context "valid message" do
      it "has no errors" do
        message_class = Class.new(Message) do
          validate do
            required(:foo)
          end
        end
        message       = message_class.new(foo: "bar")
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
        message       = message_class.new
        expect(message).to_not be_valid
        expect(message.errors[:foo]).to eq(["is missing"])
      end
    end

    describe ".decode_name" do
      it "decodes message names from URLs" do
        url     = "/@/shopping/product/list?category_slug=guitars-basses&state[step]=store"
        request = double("request", fullpath: url)
        name    = Message.decode_name(request)
        expect(name).to eq("Shopping::Product::List")
      end
    end

    describe ".decode_params" do
      it "decodes GET params" do
        request = double("request", GET: { "id" => "1", "state" => { "foo" => "bar" } }, POST: {})
        params  = Message.decode_params(request)
        expect(params).to eq({ "id" => "1", "state" => { "foo" => "bar" } })
      end

      it "decodes POST params" do
        request = double("request", GET: {}, POST: { "id" => "1", "state" => { "foo" => "bar" } })
        params  = Message.decode_params(request)
        expect(params).to eq({ "id" => "1", "state" => { "foo" => "bar" } })
      end

      it "decodes mixed params" do
        request = double("request", GET: { "id" => "1" }, POST: { "state" => { "baz" => "qux" } })
        params  = Message.decode_params(request)
        expect(params).to eq({ "id" => "1", "state" => { "baz" => "qux" } })
      end
    end
  end
end