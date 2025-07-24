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
              case val
              when "a" then class_a
              when "b" then class_b
              else fail
              end
            end
          end
          state      = { foo: { bar: "baz" }, val: "a" }
          view       = view_class.new(state)

          expect(view.foo).to be_a(class_a)
          expect(view.foo.state.to_h).to eq(bar: "baz")
        end

        it "configures the nested component" do
          foo_class = Class.new(Component::Base) do
            prop :bar, Types.integer
          end
          view      = Class.new(Component::Base) do
            param :val
            nest(:foo) { foo_class[bar: 1] }
          end.new({ val: "a" })

          expect(view.foo.parent).to eq(view)
          expect(view.foo.path).to eq("/foo")
          expect(view.foo.props.app_root).to eq("/")
          expect(view.foo.props.parent).to eq(view)
          expect(view.foo.bar).to eq(1)
        end

        it "propagates updates to the nested component" do
          foo_class   = Class.new(Component::Base) { prop :bar }
          base_class  = Class.new(Component::Base) do
            param :val
            nest(:foo) { foo_class[bar: :val] }
          end
          view        = base_class.new({ val: "1" })
          nested_view = view.foo
          view.update(val: "2")
          expect(view.foo.bar).to eq("2")
          expect(nested_view).to eq(view.foo)
        end

        it "replaces the nested component on param change" do
          foo_class   = Class.new(Component::Base) { element {} }
          bar_class   = Class.new(Component::Base) { element {} }
          base_class  = Class.new(Component::Base) do
            param :val
            nest(:foo) do |val|
              case val
              when "a" then foo_class
              when "b" then bar_class
              else fail
              end
            end
          end
          view        = base_class.new({ val: "a" }, ignore: "this")
          nested_view = view.foo
          view.update(val: "b")
          expect(nested_view).to be_a(foo_class)
          expect(view.foo).to be_a(bar_class)
          expect(view.foo).not_to eq(nested_view)
        end

        it "iterates over a collection with a key" do
          foo_class = Class.new(Component::Base) { prop :lang }
          view      = Class.new(Component::Base) do
            param :val
            let(:items) { %w[english spanish] }
            nest(:foo, over: :items) { foo_class[lang: [:items]] }
          end.new({ val: "a" })

          expect(view.foo[0]).to be_a(foo_class)
          expect(view.foo[0].lang).to eq("english")
        end
      end

      context "named constructor" do
        class NamedNestedComponent < Component::Base
          prop :var, Types.string.default("default".freeze)
          # prop :index, Types.integer
          key { props.collection_index }
          element { |var| text "Nested #{var}" }
        end

        it "nests a child component" do
          view = Class.new(Component::Base) do
            nest(:foo) { NamedNestedComponent[index: 0] }
          end.new({})
          expect(view.foo).to be_a(Component::Base)
        end

        it "nests a child component over an array" do
          view = Class.new(Component::Base) do
            let(:bar) { %w[english spanish] }
            nest(:foo, over: :bar) { NamedNestedComponent[var: [:bar]] }
          end.new({}, app_root: "/app/root")

          expect(view.foo[0]).to be_a(Component::Base)
          expect(view.foo[0].var).to eq("english")
          expect(view.foo[0].props.collection_index).to eq(0)
          expect(view.foo[0].render_full).to match /Nested english/
          expect(view.foo[0].props.app_root).to eq("/app/root")
          expect(view.foo[0].path.to_s).to eq("/foo-0")

          expect(view.foo[1]).to be_a(Component::Base)
          expect(view.foo[1].var).to eq("spanish")
          expect(view.foo[1].props.collection_index).to eq(1)
          expect(view.foo[1].render_full).to match /Nested spanish/
          expect(view.foo[1].props.app_root).to eq("/app/root")
          expect(view.foo[1].path).to eq("/foo-1")
        end
      end
    end

    describe ".slot" do
      it "accepts components as props" do
        nested = Class.new(Component::Base) { element { p "Nested content" } }
        base   = Class.new(Component::Base) do
          slot :nested
          element { div(class: "wrapper") { subview(:nested) } }
        end.new({}, nested: nested)
        expect(base.render_full).to eq('<div class="wrapper"><div id="nested" class="anon"><p>Nested content</p></div></div>')
      end
    end

  end
end