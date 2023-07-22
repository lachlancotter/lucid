require "lucid/controller"

module Lucid
  describe Controller do
    describe "#call" do
      context "no action" do
        it "performs no action" do
          action_class = Class.new(Action)
          app          = Class.new(View) do
            post :foo, action_class
          end
          controller   = Controller.new(app, "/")
          expect_any_instance_of(app).not_to receive(:perform_action)
          controller.call({})
        end
      end

      context "top level action" do
        it "performs the action" do
          action_class = Class.new(Action)
          app          = Class.new(View) do
            post :foo, action_class
          end
          controller   = Controller.new(app, "/")
          expect_any_instance_of(app).to receive(:perform_action).with("foo", {})
          controller.call("action" => "foo")
        end
      end
    end
  end
end