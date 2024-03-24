module Lucid
  describe Component::Base do

    # ===================================================== #
    #    .let
    # ===================================================== #

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

      it "accepts multiple arguments" do
        view = Class.new(Component::Base) do
          param :foo
          param :baz
          let(:bar) { |foo, baz| foo + baz }
        end.new(foo: "foo", baz: "baz")
        expect(view.bar).to eq("foobaz")
      end

      it "caches the value per instance" do
        view_class = Class.new(Component::Base) do
          let(:foo) { rand }
        end
        view1      = view_class.new
        view2      = view_class.new
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
        view.update(foo: "baz")
        expect(view.bar).to eq("BAZ")
      end

      it "re-evaluates indirect dependencies" do
        view = Class.new(Component::Base) do
          param :foo
          let(:bar) { |foo| foo.upcase }
          let(:baz) { |bar| bar }
        end.new(foo: "foo")
        expect(view.baz).to eq("FOO")
        view.update(foo: "baz")
        expect(view.baz).to eq("BAZ")
      end
    end

    # ===================================================== #
    #    .use
    # ===================================================== #

    describe ".use" do
      it "inherits let value from parent" do
        view = Class.new(Component::Base) do
          let(:foo) { "bar" }
          nest :child, Class.new(Component::Base) {
            use :foo
          }
        end.new
        expect(view.child.foo).to eq("bar")
      end

      it "inherits let values from ancestors" do
        view = Class.new(Component::Base) do
          let(:foo) { "bar" }
          nest :child, Class.new(Component::Base) {
            nest :grandchild, Class.new(Component::Base) {
              use :foo
            }
          }
        end.new
        expect(view.child.grandchild.foo).to eq("bar")
      end

      it "inherits state values" do
        view = Class.new(Component::Base) do
          param :foo
          nest :child, Class.new(Component::Base) {
            use :foo
          }
        end.new(foo: "bar")
        expect(view.child.foo).to eq("bar")
      end

      it "uses value overrides" do
        view = Class.new(Component::Base) do
          let(:foo) { "bar" }
          nest :child, Class.new(Component::Base) {
            let(:foo) { "baz" }
            nest :grandchild, Class.new(Component::Base) {
              use :foo
            }
          }
        end.new
        expect(view.child.grandchild.foo).to eq("baz")
      end

      it "raises when undefined" do
        view = Class.new(Component::Base) do
          use :foo
        end.new
        expect { view.foo }.to raise_error(Component::Dataflow::Field::NoSuchField)
      end
    end

    # ===================================================== #
    #    .watch
    # ===================================================== #

    describe ".watch" do
      it "executes the block when the value changes" do
        bar = nil
        view = Class.new(Component::Base) do
          param :foo, default: ""
          watch(:foo) { bar = "foo" }
        end.new
        view.update(foo: "foo")
        expect(bar).to eq("foo")
      end

      it "accepts multiple values" do
        baz = 0
        view = Class.new(Component::Base) do
          param :foo, default: ""
          param :bar, default: ""
          watch(:foo, :bar) { baz += 1 }
        end.new
        view.update(foo: "foo")
        view.update(bar: "bar")
        expect(baz).to eq(2)
      end

      it "watches dependent fields" do
        calls = 0
        view = Class.new(Component::Base) do
          param :foo, default: ""
          let(:bar) { |foo| foo.upcase }
          watch(:bar) { calls += 1 }
        end.new
        expect(view.bar).to eq("")
        view.update(foo: "foo")
        expect(view.bar).to eq("FOO")
        expect(calls).to eq(1)
      end
    end

  end
end