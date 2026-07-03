module Lucid
  describe Link do
    describe "#query_params" do
      it "includes params" do
        MyLink2 = Class.new(Link)
        link    = MyLink2.new(foo: "bar")
        expect(link.query_params).to eq({ foo: "bar" })
      end
    end
  end
end
