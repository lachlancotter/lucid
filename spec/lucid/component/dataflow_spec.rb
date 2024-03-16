module Lucid
  describe Component::Base do

    describe ".let" do
      it "evaluates the block" do
        view = Class.new(Component::Base) do
          let(:foo) { "bar" }
        end.new
        expect(view.foo).to eq("bar")
      end

      it "accepts arguments" do
        view = Class.new(Component::Base) do
          param :foo
          let(:bar) { |foo| foo.upcase }
        end.new(foo: "foo")
        expect(view.bar).to eq("FOO")
      end

      it "caches the value per instance" do
        view_class = Class.new(Component::Base) do
          let(:foo) { rand }
        end
        view1 = view_class.new
        view2 = view_class.new
        expect(view1.foo).to eq(view1.foo)
        expect(view2.foo).to eq(view2.foo)
        expect(view1.foo).not_to eq(view2.foo)
      end

      it "re-evaluates when dependencies change" do
        view = Class.new(Component::Base) do
          param :foo
          let(:bar) { |foo| foo.upcase }
        end.new(foo: "foo")
        expect(view.bar).to eq("FOO")
        view.state.update(foo: "baz")
        expect(view.bar).to eq("BAZ")
      end

    end

  end
end