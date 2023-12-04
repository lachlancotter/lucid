module Lucid
  describe Component::Nestable do
    describe ".nest" do
      context "dynamic constructor" do
        it "constructs with the given block" do
          foo_class = Class.new(Component::Base)

          view = Class.new(Component::Base) do
            nest :foo do |foo_state|
              foo_class.new(foo_state)
            end
          end.new(foo: { bar: "baz" })

          expect(view.foo).to be_a(foo_class)
          expect(view.foo.state).to eq(bar: "baz")
        end

        it "configures the nested instance" do
          foo_class = Class.new(Component::Base)
          view = Class.new(Component::Base) do
            nest :foo do |foo_state|
              foo_class.new(foo_state)
            end
          end.new(foo: { bar: "baz" })

          expect(view.foo.path).to eq("/foo")
          expect(view.foo.app_root).to eq("/")
        end

        it "iterates over a given collection" do
          foo_class = Class.new(Component::Base) do
            setting :bar
          end
          view = Class.new(Component::Base) do
            nest :foo, in: %w[english spanish], as: :bar do |foo_state|
              foo_class.new(foo_state)
            end
          end.new

          expect(view.foo(0)).to be_a(foo_class)
          expect(view.foo(0).bar).to eq("english")
        end
      end

      context "named constructor" do
        class NamedNestedComponent < Component::Base
          setting :bar
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
            nest :foo, NamedNestedComponent, in: %w[english spanish], as: :bar
          end.new do |config|
            config.app_root = "/app/root"
          end

          expect(view.foo(0)).to be_a(Component::Base)
          expect(view.foo(0).config.bar).to eq("english")
          expect(view.foo(0).render).to eq("Nested english")
          expect(view.foo(0).config.app_root).to eq("/app/root")
          expect(view.foo(0).config.path).to eq("/foo[0]")

          expect(view.foo(1)).to be_a(Component::Base)
          expect(view.foo(1).config.bar).to eq("spanish")
          expect(view.foo(1).render).to eq("Nested spanish")
          expect(view.foo(1).config.app_root).to eq("/app/root")
          expect(view.foo(1).config.path).to eq("/foo[1]")
        end

      end
    end
  end
end