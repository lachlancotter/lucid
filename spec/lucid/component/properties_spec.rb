module Lucid
  describe Component::Properties do
    describe ".prop" do
      it "defines a property" do
        view_class = Class.new(Component::Base) { prop :foo }
        view       = view_class.new({}, foo: "bar")
        expect(view.foo).to eq("bar")
      end

      it "accepts a default value" do
        view_class = Class.new(Component::Base) { prop :foo, Types.string.default("bar".freeze) }
        view       = view_class.new({})
        expect(view.foo).to eq("bar")
      end

      it "overrides the default" do
        view_class = Class.new(Component::Base) { prop :foo, Types.string.default("bar".freeze) }
        view = view_class.new({}, foo: "baz")
        expect(view.foo).to eq("baz")
      end

      it "calls the constructor" do
        view_class = Class.new(Component::Base) do
          prop :foo, Types.string.constructor { |value| value.upcase }
        end
        view       = view_class.new({}, foo: "bar")
        expect(view.foo).to eq("BAR")
      end

      describe "inheritance" do
        it "inherits defaults from parent class" do
          super_class = Class.new(Component::Base) { prop :foo, Types.string.default("bar".freeze) }
          sub_class   = Class.new(super_class)
          view        = sub_class.new({})
          expect(view.foo).to eq("bar")
        end

        it "declares new values in subclasses" do
          super_class = Class.new(Component::Base) { prop :foo, Types.string.default("bar".freeze) }
          sub_class   = Class.new(super_class) { prop :baz, Types.string.default("qux".freeze) }
          view        = sub_class.new({})
          expect(view.foo).to eq("bar")
          expect(view.baz).to eq("qux")
        end
      end

      describe "standard properties" do
        it "has a name" do
          view = Class.new(Component::Base).new({})
          expect(view.props.name).to eq("root")
        end

        it "has a root" do
          view = Class.new(Component::Base).new({})
          expect(view.props.app_root).to eq("/")
          expect(view.props[:app_root]).to eq("/")
        end
      end


    end
  end
end