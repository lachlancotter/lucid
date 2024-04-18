module Lucid
  describe Link::Scoped do
    describe "#query_params" do
      it "includes the link name" do
        component = Class.new(Component::Base).new({})
        link      = Link::Scoped.new(component, :inc, {})
        Message.with_context(component) do
          expect(link.query_params).to include("name" => "inc")
        end
      end

      it "includes the link params" do
        component = Class.new(Component::Base).new({})
        link      = Link::Scoped.new(component, :inc, { foo: "bar" })
        Message.with_context(component) do
          expect(link.query_params).to include("foo" => "bar")
        end
      end

      it "includes the component path" do
        component = Class.new(Component::Base).new({}) { { path: %w[a b c] } }
        link      = Link::Scoped.new(component, :inc, { foo: "bar" })
        Message.with_context(component) do
          expect(link.query_params).to include({ "scope" => "/a/b/c" })
        end
      end
    end
  end

  describe Link do
    describe "#query_params" do
      it "includes params" do
        MyLink2 = Class.new(Link)
        link    = MyLink2.new(foo: "bar")
        expect(link.query_params).to eq({ "foo" => "bar" })
      end
    end
  end
end