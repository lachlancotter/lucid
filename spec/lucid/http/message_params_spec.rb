module Lucid
  module HTTP
    describe MessageParams do
      it "filters nil keys from raw params" do
        params = MessageParams.new({
           nil     => "broken",
           "foo"   => "bar",
           "state" => {
              nil   => "bad state",
              "baz" => "qux"
           }
        })

        expect(params.to_h).to eq(foo: "bar", state: { baz: "qux" })
        expect(params.state).to eq(baz: "qux")
      end
    end
  end
end
