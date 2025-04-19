module Lucid
  module HTML
    describe Button do
      TestMessage = Class.new(Command) do
        validate { required(:foo).filled(:string) }
      end

      it "passes message parameters" do
        message = TestMessage.new(foo: "bar")
        button  = Button.new(message, "Submit")
        expect(button.to_s).to include("foo")
      end

      it "passes state" do
        message = TestMessage.new(foo: "bar")
        button  = Button.new(message, "Submit")
        HTTP::Message.with_state(baz: "qux") do
          expect(button.to_s).to include("state[baz]=qux")
        end
      end
    end
  end
end