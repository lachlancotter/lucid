require "lucid/component/state_mapping"

module Lucid
  describe Component::StateMapping do

    describe ".url" do
      context "no path" do
        it "is the empty path" do
          view = Class.new(Component::Base) {}.new({})
          expect(view.url.to_s).to eq("/")
        end
      end

      it "maps params to path segments" do
        component_class = Class.new(Component::Base) do
          route ":foo/:bar"
          param :foo, Types.string
          param :bar, Types.string
        end
        instance        = component_class.new({ foo: "first", bar: "second" })
        expect(instance.url).to eq("/first/second")
      end

      it "maps string literals to path segments" do
        component_class = Class.new(Component::Base) do
          route "literal/:foo"
          param :foo, Types.string
        end
        instance        = component_class.new({ foo: "var" })
        expect(instance.url).to eq("/literal/var")
      end

      it "nests a subcomponent" do
        component_class = Class.new(Component::Base) do
          route ":foo", nest: :bar
          param :foo, Types.string
          nest :bar do
            Class.new(Component::Base) do
              route ":baz"
              param :baz, Types.string
            end
          end
          nest :not_on_path do
            Class.new(Component::Base) do
              route ":quox"
              param :quox, Types.string
            end
          end
        end
        state           = { foo: "foo", bar: { baz: "baz" }, not_on_path: { quox: "quox" } }
        instance        = component_class.new(state)
        expect(instance.url).to eq("/foo/baz?not_on_path[quox]=quox")
      end

      it "raises when segments are undefined" do
        component_class = Class.new(Component::Base) { route ":foo" }
        instance        = component_class.new({})
        expect { instance.url }.to raise_error(State::Map::MissingValue)
      end

      it "ignores leading and trailing slashes" do
        component_class = Class.new(Component::Base) do
          route "/:foo/:bar/"
          param :foo, Types.string
          param :bar, Types.string
        end
        instance        = component_class.new({ foo: "first", bar: "second" })
        expect(instance.url).to eq("/first/second")
      end
    end

    describe ".param" do
      it "defines query params" do
        component_class = Class.new(Component::Base) { param :foo }
        instance        = component_class.new({ foo: "bar" })
        expect(instance.state.foo).to eq("bar")
      end

      it "sets defaults" do
        component_class = Class.new(Component::Base) { param :count, Types.integer.default(1) }
        instance        = component_class.new({})
        expect(instance.state.count).to eq(1)
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
          expect { component_class.new(count: "foo") }.to raise_error(ParamError)
        end
      end
    end

  end
end