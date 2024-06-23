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
        app     = Class.new do
          def merge_state (params)
            params.merge(state: { baz: "qux" })
          end
        end.new
        button  = Button.new(message, "Submit")
        HttpMessage.with_app_state(app) do
          expect(button.to_s).to include("state[baz]=qux")
        end
      end
    end
  end
end