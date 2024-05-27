require "lucid/component/state_map"

module Lucid
  describe Component::StateMap do

    describe ".path" do
      it "defines path params" do
        component_class = Class.new(Component::Base) { path :foo }
        instance        = component_class.new(foo: "bar")
        expect(instance.state.foo).to eq("bar")
      end

      it "accepts a type" do
        component_class = Class.new(Component::Base) { path :count, Types.integer }
        component       = component_class.new(count: "1")
        expect(component.state.count).to eq(1)
      end

      it "sets defaults" do
        component_class = Class.new(Component::Base) { path :count, Types.integer.default(1) }
        instance        = component_class.new({})
        expect(instance.state.count).to eq(1)
      end
    end

    describe ".param" do
      it "defines query params" do
        component_class = Class.new(Component::Base) { param :foo }
        instance        = component_class.new(foo: "bar")
        expect(instance.state.foo).to eq("bar")
      end

      it "sets defaults" do
        component_class = Class.new(Component::Base) { param :count, Types.integer.default(1) }
        instance        = component_class.new({})
        expect(instance.state.count).to eq(1)
      end
    end

    describe "#href" do
      context "no path" do
        it "is the empty path" do
          view = Class.new(Component::Base) {}.new
          expect(view.href.to_s).to eq("/")
        end
      end

      context "single param in path" do
        it "includes the param" do
          component_class = Class.new(Component::Base) { path :foo }
          instance        = component_class.new(foo: "bar")
          expect(instance.href.to_s).to eq("/bar")
        end
      end

      context "multiple params in path" do
        it "includes the params" do
          view = Class.new(Component::Base) do
            path :foo, Types.integer.default(1)
            path :bar, Types.integer.default(2)
          end.new
          expect(view.href.to_s).to eq("/1/2")
        end
      end

      context "literal in path" do
        it "includes the literal" do
          view = Class.new(Component::Base) do
            path "resource"
            path :id, Types.integer.default(1)
          end.new
          expect(view.href.to_s).to eq("/resource/1")
        end
      end
    end

    context "nested path" do
      it "includes the nested path" do
        top = Class.new(Component::Base) do
          path :foo, Types.string.default("top".freeze), nest: :bar
          nest :bar do
            Class.new(Component::Base) {
              path :bar, Types.string.default("nested".freeze)
            }
          end
        end.new
        expect(top.href.to_s).to eq("/top/nested")
      end
    end

    context "multiple nested components" do
      it "includes the nested path" do
        top = Class.new(Component::Base) do
          path :foo, Types.string.default("top".freeze), nest: :bar
          nest :bar do
            Class.new(Component::Base) {
              path :bar, Types.string.default("nested".freeze)
            }
          end
          nest :baz do
            Class.new(Component::Base) {
              param :quox, Types.string.default("quox")
            }
          end
        end.new
        expect(top.href.to_s).to eq("/top/nested?baz[quox]=quox")
      end
    end

    context "multiple nested path components" do
      it "nests only one path" do
        top = Class.new(Component::Base) do
          path :foo, Types.string.default("top".freeze)

          nest :bar do
            Class.new(Component::Base) {
              path :bar, Types.string.default("nested".freeze)
            }
          end
          nest :baz do
            Class.new(Component::Base) {
              param :baz, Types.string.default("baz".freeze)
            }
          end
        end.new
        expect(top.href.to_s).to eq("/top/nested?baz[baz]=baz")
      end
    end

    describe "validation" do
      context "valid data" do
        it "constructs the component" do
          component_class = Class.new(Component::Base) do
            param :count, Types.integer
          end
          expect { component_class.new(count: "1") }.not_to raise_error
        end
      end

      context "invalid data" do
        it "raises en error" do
          component_class = Class.new(Component::Base) do
            param :count, Types.integer
          end
          expect { component_class.new(count: "foo") }.to raise_error(Dry::Types::CoercionError)
        end
      end
    end

  end
end