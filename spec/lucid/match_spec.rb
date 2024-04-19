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

    context "tuple match" do
      it "matches arguments by order" do
        match = Match.new("foo", "bar").match do
          value("foo", "false") { "no match" }
          value("bar", "false") { "no match" }
          value("false", "bar") { "no match" }
          value("foo", "bar") { "match" }
        end
        expect(match).to eq("match")
      end
    end
  end
end