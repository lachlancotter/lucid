module Lucid
  module Component
    describe Temps do
      describe ".temp" do
        it "defines a temporary value" do
          view_class = Class.new(Component::Base) { temp :foo }
          view       = view_class.new({})
          expect(view.foo).to be_nil
        end

        it "accepts a default" do
          view_class = Class.new(Component::Base) { temp :foo, Types.string.default("bar".freeze) }
          view       = view_class.new({})
          expect(view.foo).to eq("bar")
        end
      end

      describe "#touch" do
        it "updates temporary fields" do
          msg_class  = Class.new(Lucid::Event)
          view_class = Class.new(Component::Base) do
            temp :foo
            on(msg_class) { touch(foo: "bar") }
          end
          view       = view_class.new({}, msg_class.new)
          expect(view.foo).to eq("bar")
        end
      end
    end
  end
end