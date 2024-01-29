module Lucid
  describe Link::Scoped do
    describe "#query_params" do
      it "includes the link name" do
        component = Class.new(Component::Base).new({})
        link      = Link::Scoped.new(component, :inc, {})
        expect(link.query_params["msg"]).to include("name" => "inc")
      end

      it "includes the link params" do
        component = Class.new(Component::Base).new({})
        link      = Link::Scoped.new(component, :inc, { foo: "bar" })
        expect(link.query_params["msg"]["args"]).to include("foo" => "bar")
      end

      it "includes the component path" do
        component = Class.new(Component::Base).new({}) do |config|
          config.path = %w[a b c]
        end
        link      = Link::Scoped.new(component, :inc, { foo: "bar" })
        expect(link.query_params["msg"]).to include({ "scope" => "/a/b/c" })
      end
    end
  end

  describe Link do
    describe "#query_params" do
      it "includes the link name" do
        MyLink1 = Class.new(Link)
        link    = MyLink1.new
        expect(link.query_params["msg"]).to include({ "name" => "Lucid-MyLink1" })
      end

      it "includes params" do
        MyLink2 = Class.new(Link)
        link    = MyLink2.new(foo: "bar")
        expect(link.query_params).to eq({
           "msg" => {
              "name" => "Lucid-MyLink2",
              "args" => {
                 "foo" => "bar"
              }
           }
        })
      end
    end
  end
end