module Lucid
  describe Component::Nesting do
    describe ".nest" do
      context "dynamic constructor" do
        it "constructs with the given block" do
          class_a = Class.new(Component::Base)
          class_b = Class.new(Component::Base)

          view = Class.new(Component::Base) do
            param :val
            nest :foo do |val|
              match(val) do
                is("a") { class_a }
                is("b") { class_b }
              end
            end
          end.new(foo: { bar: "baz" }, val: "a")

          expect(view.foo).to be_a(class_a)
          expect(view.foo.state).to eq(bar: "baz")
        end

        it "configures the nested instance" do
          foo_class = Class.new(Component::Base)
          view      = Class.new(Component::Base) do
            param :val
            nest(:foo) { foo_class }
          end.new(foo: { bar: "baz" }, val: "a")

          expect(view.foo.path).to eq("/foo")
          expect(view.foo.app_root).to eq("/")
        end

        it "iterates over a given collection" do
          foo_class = Class.new(Component::Base) { setting :bar }
          view      = Class.new(Component::Base) do
            param :val
            nest :foo do
              foo_class.enum(%w[english spanish]) { |e| { bar: e } }
            end
          end.new(val: "a")

          expect(view.foo(0)).to be_a(foo_class)
          expect(view.foo(0).bar).to eq("english")
        end
      end

      context "named constructor" do
        class NamedNestedComponent < Component::Base
          setting :bar
          setting :index

          def render
            "Nested #{config[:bar]}"
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
          end.new do |config|
            config.app_root = "/app/root"
          end

          expect(view.foo(0)).to be_a(Component::Base)
          expect(view.foo(0).config.bar).to eq("english")
          expect(view.foo(0).config.index).to eq(0)
          expect(view.foo(0).render).to eq("Nested english")
          expect(view.foo(0).config.app_root).to eq("/app/root")
          expect(view.foo(0).config.path.to_s).to eq("/foo[0]")

          expect(view.foo(1)).to be_a(Component::Base)
          expect(view.foo(1).config.bar).to eq("spanish")
          expect(view.foo(1).config.index).to eq(1)
          expect(view.foo(1).render).to eq("Nested spanish")
          expect(view.foo(1).config.app_root).to eq("/app/root")
          expect(view.foo(1).config.path).to eq("/foo[1]")
        end

      end
    end
  end
end