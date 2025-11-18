module Lucid
  module Util
    describe Fields do
      describe ".let" do
        it "evaluates the block" do
          view = Class.new(Component::Base) do
            let(:foo) { "bar" }
          end.new({})
          expect(view.foo).to eq("bar")
        end

        it "accepts arguments" do
          view = Class.new(Component::Base) do
            param :foo
            let(:bar) { |foo| foo.upcase }
          end.new({ foo: "foo" })
          expect(view.bar).to eq("FOO")
        end

        it "accepts multiple arguments" do
          view = Class.new(Component::Base) do
            param :foo
            param :baz
            let(:bar) { |foo, baz| foo + baz }
          end.new({ foo: "foo", baz: "baz" })
          expect(view.bar).to eq("foobaz")
        end

        it "accepts property arguments" do
          view = Class.new(Component::Base) do
            prop :foo
            let(:bar) { |foo| foo.upcase }
          end.new({}, foo: "foo")
          expect(view.bar).to eq("FOO")
        end

        it "caches the value per instance" do
          view_class = Class.new(Component::Base) do
            let(:foo) { rand }
          end
          view1      = view_class.new({})
          view2      = view_class.new({})
          expect(view1.foo).to eq(view1.foo)
          expect(view2.foo).to eq(view2.foo)
          expect(view1.foo).not_to eq(view2.foo)
        end

        it "re-evaluates when dependencies change" do
          msg_class       = Class.new(Lucid::Event)
          component_class = Class.new(Component::Base) do
            param :foo
            on(msg_class) { update(foo: "baz") }
            let(:bar) { |foo| foo.upcase }
          end

          view = component_class.new({ foo: "foo" })
          expect(view.bar).to eq("FOO")
          view = component_class.new({ foo: "foo" }, msg_class.new)
          expect(view.bar).to eq("BAZ")
        end

        it "re-evaluates indirect dependencies" do
          msg_class       = Class.new(Lucid::Event)
          component_class = Class.new(Component::Base) do
            param :foo
            on(msg_class) { update(foo: "baz") }
            let(:bar) { |foo| foo.upcase }
            let(:baz) { |bar| bar }
          end
          view            = component_class.new({ foo: "foo" })
          expect(view.baz).to eq("FOO")
          view = component_class.new({ foo: "foo" }, msg_class.new)
          expect(view.baz).to eq("BAZ")
        end
      end

      describe ".map" do
        it "maps a block over a signal" do
          component_class = Class.new(Component::Base) do
            let(:foo) { %w[a b c] }
            map(:bar, over: :foo) { |f| f.upcase }
          end
          component       = component_class.new({})
          expect(component.bar).to eq(%w[A B C])
        end

        it "maps with index" do
          component_class = Class.new(Component::Base) do
            let(:foo) { %w[a b c] }
            map(:bar, over: :foo) { |f, i| [i, f.upcase] }
          end
          component       = component_class.new({})
          expect(component.bar).to eq([[0, "A"], [1, "B"], [2, "C"]])
        end

        it "receives signal dependencies" do
          component_class = Class.new(Component::Base) do
            let(:foo) { %w[a b c] }
            let(:baz) { "BAZ" }
            map(:bar, over: :foo) { |f, baz:| "#{baz}:#{f.upcase}" }
          end
          component       = component_class.new({})
          expect(component.bar).to eq(["BAZ:A", "BAZ:B", "BAZ:C"])
        end

        it "invalidates when dependencies change" do
          component_class = Class.new(Component::Base) do
            let(:foo) { %w[a b c] }
            map(:bar, over: :foo) { |f| f }
          end
          component       = component_class.new({})
          invalidated     = false
          component.field(:bar).attach(self) { invalidated = true }
          component.field(:foo).invalidate
          expect(invalidated).to be true
        end
      end

      describe ".watch" do
        it "executes the block when the value changes" do
          bar             = nil
          msg_class       = Class.new(Lucid::Event)
          component_class = Class.new(Component::Base) do
            param :foo, Types.string.default("".freeze)
            on(msg_class) { update(foo: "foo") }
            watch(:foo) { bar = "foo" }
          end
          component_class.new({}, msg_class.new)
          expect(bar).to eq("foo")
        end

        it "accepts multiple values" do
          baz             = 0
          msg_class       = Class.new(Lucid::Event)
          component_class = Class.new(Component::Base) do
            param :foo, Types.string.default("".freeze)
            param :bar, Types.string.default("".freeze)
            on(msg_class) { update(foo: "foo", bar: "bar") }
            watch(:foo, :bar) { baz += 1 }
          end
          component_class.new({}, msg_class.new)
          expect(baz).to eq(2)
        end

        it "watches dependent fields" do
          calls           = 0
          msg_class       = Class.new(Lucid::Event)
          component_class = Class.new(Component::Base) do
            param :foo, Types.string.default("".freeze)
            on(msg_class) { update(foo: "foo") }
            let(:bar) { |foo| foo.upcase }
            watch(:bar) { calls += 1 }
          end
          view            = component_class.new({})
          expect(view.state.foo).to eq("")
          expect(view.bar).to eq("")

          view = component_class.new({}, msg_class.new)
          expect(view.bar).to eq("FOO")
          expect(calls).to eq(1)
        end
      end
    end
  end
end