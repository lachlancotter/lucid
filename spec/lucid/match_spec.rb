module Lucid
  describe Match do
    context "match" do
      it "returns the value of the matching block" do
        match = Match.new("foo").match do
          value("foo") { "bar" }
        end
        expect(match).to eq("bar")
      end
    end

    context "no match" do
      it "raises no match" do
        expect {
          Match.new("foo").match do
            value("bar") { "baz" }
          end
        }.to raise_error(Match::NoMatch)
      end
    end

    context "default" do
      it "returns the default value" do
        match = Match.new("foo").match do
          value("bar") { "baz" }
          value("qux") { "quux" }
          default { "corge" }
        end
        expect(match).to eq("corge")
      end
    end
  end
end