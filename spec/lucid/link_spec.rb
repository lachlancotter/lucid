module Lucid
  describe Link::Local do
    describe "#to_params" do
      it "includes the link name" do
        component = Class.new(Component).new({})
        link      = Link::Local.new(:inc, {}, component)
        expect(link.to_params).to include({ msg: "inc" })
      end

      it "includes the link params" do
        component = Class.new(Component).new({})
        link      = Link::Local.new(:inc, { foo: "bar" }, component)
        expect(link.to_params).to include({ inc: { foo: "bar" } })
      end

      it "includes the component path" do
        component = Class.new(Component).new({}) do |config|
          config.path = %w[a b c]
        end
        link     = Link::Local.new(:inc, { foo: "bar" }, component)
        expect(link.to_params).to include({ path: "/a/b/c" })
      end

      it "includes context" do
        component = Class.new(Component).new({}) do |config|
          config.path = %w[a b c]
        end
        app       = double("app", params: { baz: "qux" })
        Link.with_context(app) do
          link = Link::Local.new(:inc, { foo: "bar" }, component)
          expect(link.to_params).to include({ baz: "qux" })
        end
      end
    end
  end

  describe Link do
    describe "#to_params" do
      it "includes the link name" do
        MyLink1 = Class.new(Link)
        link    = MyLink1.new
        expect(link.to_params).to include({ msg: "Lucid::MyLink1" })
      end

      it "includes params" do
        MyLink2 = Class.new(Link)
        link    = MyLink2.new(foo: "bar")
        expect(link.to_params).to eq({
           msg:              "Lucid::MyLink2",
           "Lucid::MyLink2": {
              foo: "bar"
           }
        })
      end

      it "includes context" do
        MyLink3 = Class.new(Link)
        app     = double("app", params: { baz: "qux" })
        Link.with_context(app) do
          link = MyLink3.new(foo: "bar")
          expect(link.to_params).to eq({
             baz:              "qux",
             msg:              "Lucid::MyLink3",
             "Lucid::MyLink3": {
                foo: "bar"
             }
          })
        end
      end
    end

    describe "#to_query" do
      it "renders the query string" do
        MyLink4 = Class.new(Link)
        link    = MyLink4.new(foo: "bar")
        expect(link.to_query).to eq("?Lucid%3A%3AMyLink4=%7B%3Afoo%3D%3E%22bar%22%7D&msg=Lucid%3A%3AMyLink4")
      end
    end
  end
end