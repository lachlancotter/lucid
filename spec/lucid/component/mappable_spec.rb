require "lucid/component/mappable"

module Lucid
  describe Component::Mappable do

    describe ".path" do
      it "defines path params" do
        instance = Class.new(Component::Base) do
          path :foo
        end.new(foo: "bar")
        expect(instance.foo).to eq("bar")
      end

      it "sets defaults" do
        instance = Class.new(Component::Base) do
          path :count, default: 1
        end.new({})
        expect(instance.count).to eq(1)
      end
    end

    describe ".param" do
      it "defines query params" do
        component_class = Class.new(Component::Base) do
          param :foo
        end
        instance        = component_class.new(foo: "bar")
        expect(instance.foo).to eq("bar")
      end

      it "sets defaults" do
        component_class = Class.new(Component::Base) do
          param :count, default: 1
        end
        instance        = component_class.new({})
        expect(component_class.state_class.defaults).to eq(count: 1)
        expect(instance.count).to eq(1)
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
          view = Class.new(Component::Base) do
            path :foo
          end.new(foo: "bar")
          expect(view.href.to_s).to eq("/bar")
        end
      end

      context "multiple params in path" do
        it "includes the params" do
          view = Class.new(Component::Base) do
            path :foo, :bar, defaults: [1, 2]
          end.new
          expect(view.href.to_s).to eq("/1/2")
        end
      end

      context "literal in path" do
        it "includes the literal" do
          view = Class.new(Component::Base) do
            path "resource", :id, default: 1
          end.new
          expect(view.href.to_s).to eq("/resource/1")
        end
      end
    end

    context "nested path" do
      it "includes the nested path" do
        top = Class.new(Component::Base) do
          path :foo, nest: :bar, default: "top"
          nest :bar, Class.new(Component::Base) {
            path :bar, default: "nested"
          }
        end.new
        expect(top.href.to_s).to eq("/top/nested")
      end
    end

    context "multiple nested components" do
      it "includes the nested path" do
        top = Class.new(Component::Base) do
          path :foo, nest: :bar, defaults: ["top"]
          nest :bar, Class.new(Component::Base) {
            path :bar, default: "nested"
          }
          nest :baz, Class.new(Component::Base) {
            param :quox, default: "quox"
          }
        end.new
        expect(top.href.to_s).to eq("/top/nested?baz[quox]=quox")
      end
    end

    context "multiple nested path components" do
      it "nests only one path" do
        # top.map("/:foo", :bar) do |bar|
        #   bar.map("/:bar")
        # end

        top = Class.new(Component::Base) do
          path :foo, defaults: ["top"]

          nest :bar, Class.new(Component::Base) {
            path :bar, default: "nested"
          }, path: true
          nest :baz, Class.new(Component::Base) {
            param :baz, default: "baz"
          }
        end.new
        expect(top.href.to_s).to eq("/top/nested?baz[baz]=baz")
      end
    end

  end
end