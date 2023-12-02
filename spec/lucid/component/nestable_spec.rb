module Lucid
  describe Component::Nestable do
    describe ".nest" do
      context "inline" do
        it "nests a child component" do
          view = Class.new(Component::Base) do
            nest :foo do
              def render
                "Nested"
              end
            end
          end.new
          expect(view.foo).to be_a(Component::Base)
          expect(view.foo.render).to eq("Nested")
        end

        it "nests a child component over an array" do
          view = Class.new(Component::Base) do
            nest :foo, in: %w[english spanish], as: :bar do
              setting :bar
              def render
                "Nested #{config.bar}"
              end
            end
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

        it "nests a child component over a collection reference" do
          view = Class.new(Component::Base) do
            def languages
              %w[english spanish]
            end

            nest :foo, in: :languages, as: :bar do
              setting :bar
              def render
                "Nested #{config[:bar]}"
              end
            end
          end.new do |config|
            config.app_root = "/app/root"
          end
          expect(view.foo(0)).to be_a(Component::Base)
          expect(view.foo(0).render).to eq("Nested english")
          expect(view.foo(0).config.app_root).to eq("/app/root")
          expect(view.foo(0).config.path).to eq("/foo[0]")
          expect(view.foo(0).config.bar).to eq("english")

          expect(view.foo(1)).to be_a(Component::Base)
          expect(view.foo(1).render).to eq("Nested spanish")
          expect(view.foo(1).config.app_root).to eq("/app/root")
          expect(view.foo(1).config.path).to eq("/foo[1]")
          expect(view.foo(1).config.bar).to eq("spanish")
        end
      end

      context "named constant" do
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