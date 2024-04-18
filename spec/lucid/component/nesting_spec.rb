module Lucid
  describe Component::Nesting do
    describe ".nest" do

      context "dynamic constructor" do
        it "constructs with the given block" do
          class_a = Class.new(Component::Base) { param :bar }
          class_b = Class.new(Component::Base)

          view_class = Class.new(Component::Base) do
            param :val
            nest :foo do |val|
              Match.on(val) do
                value("a") { class_a }
                value("b") { class_b }
              end
            end
          end
          view = view_class.new(foo: { bar: "baz" }, val: "a")

          expect(view.foo).to be_a(class_a)
          expect(view.foo.state).to eq(bar: "baz")
        end

        it "configures the nested instance" do
          foo_class = Class.new(Component::Base)
          view      = Class.new(Component::Base) do
            param :val
            nest(:foo) { foo_class }
          end.new(foo: { bar: "baz" }, val: "a")

          expect(view.foo.props.path).to eq("/foo")
          expect(view.foo.props.app_root).to eq("/")
        end

        it "iterates over a given collection" do
          foo_class = Class.new(Component::Base) { prop :bar }
          view      = Class.new(Component::Base) do
            param :val
            nest :foo do
              foo_class.enum(%w[english spanish]) { |e| { bar: e } }
            end
          end.new(val: "a")

          expect(view.foo(0)).to be_a(foo_class)
          expect(view.foo(0).props.bar).to eq("english")
        end
      end

      context "named constructor" do
        class NamedNestedComponent < Component::Base
          prop :bar
          prop :index

          def render
            "Nested #{props[:bar]}"
          end
        end

        it "nests a child component" do
          view = Class.new(Component::Base) do
            nest :foo, NamedNestedComponent
          end.new
          expect(view.foo).to be_a(Component::Base)
        end

        it "nests a child component over an array" do
          view = Class.new(Component::Base) do
            nest :foo do
              NamedNestedComponent.enum(%w[english spanish]) do |e, i|
                { bar: e, index: i }
              end
            end
          end.new { { app_root: "/app/root" } }

          expect(view.foo(0)).to be_a(Component::Base)
          expect(view.foo(0).props.bar).to eq("english")
          expect(view.foo(0).props.index).to eq(0)
          expect(view.foo(0).render).to eq("Nested english")
          expect(view.foo(0).props.app_root).to eq("/app/root")
          expect(view.foo(0).props.path.to_s).to eq("/foo[0]")

          expect(view.foo(1)).to be_a(Component::Base)
          expect(view.foo(1).props.bar).to eq("spanish")
          expect(view.foo(1).props.index).to eq(1)
          expect(view.foo(1).render).to eq("Nested spanish")
          expect(view.foo(1).props.app_root).to eq("/app/root")
          expect(view.foo(1).props.path).to eq("/foo[1]")
        end

      end
    end
  end
end