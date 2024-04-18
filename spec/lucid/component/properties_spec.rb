module Lucid
  describe Component::Properties do
    describe ".prop" do
      it "defines a property" do
        view_class = Class.new(Component::Base) { prop :foo }
        view       = view_class.new { { foo: "bar" } }
        expect(view.props.foo).to eq("bar")
      end

      it "accepts a default value" do
        view_class = Class.new(Component::Base) { prop :foo, default: "bar" }
        view       = view_class.new
        expect(view.props.foo).to eq("bar")
      end

      it "overrides the default" do
        view_class = Class.new(Component::Base) { prop :foo, default: "bar" }
        view = view_class.new { { foo: "baz" } }
        expect(view.props.foo).to eq("baz")
      end

      it "calls the constructor" do
        view_class = Class.new(Component::Base) do
          prop(:foo) { |value| value.upcase }
        end
        view       = view_class.new { { foo: "bar" } }
        expect(view.props.foo).to eq("BAR")
      end

      describe "inheritance" do
        it "inherits defaults from parent class" do
          super_class = Class.new(Component::Base) { prop :foo, default: "bar" }
          sub_class   = Class.new(super_class)
          view        = sub_class.new
          expect(view.props.foo).to eq("bar")
        end

        it "declares new values in subclasses" do
          super_class = Class.new(Component::Base) { prop :foo, default: "bar" }
          sub_class   = Class.new(super_class) { prop :baz, default: "qux" }
          view        = sub_class.new
          expect(view.props.foo).to eq("bar")
          expect(view.props.baz).to eq("qux")
        end
      end

      describe "standard properties" do
        it "has a path" do
          view = Class.new(Component::Base).new
          expect(view.props.path).to eq("/")
          expect(view.props[:path]).to eq("/")
        end

        it "has a root" do
          view = Class.new(Component::Base).new
          expect(view.props.app_root).to eq("/")
          expect(view.props[:app_root]).to eq("/")
        end
      end


    end
  end
end