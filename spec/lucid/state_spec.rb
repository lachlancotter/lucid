module Lucid
  describe State do
    context "simple state" do
      it "sets state" do
        state_class = Class.new(State::Base) do
          attribute :foo
        end
        state       = state_class.new(foo: "bar")
        expect(state.foo).to eq("bar")
      end

      it "sets defaults" do
        state_class = Class.new(State::Base) { attribute :count, Types.integer.default(1) }
        state       = state_class.new({})
        expect(state.count).to eq(1)
      end

      it "validates input" do
        state_class = Class.new(State::Base) do
          attribute :count, Types.integer
        end
        state       = state_class.new(count: "2")
        expect(state.count).to eq(2)
      end
    end
  end

end