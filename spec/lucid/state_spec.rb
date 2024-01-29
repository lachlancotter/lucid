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
        state_class = Class.new(State::Base) do
          attribute :count, default: 1
        end
        state       = state_class.new({})
        expect(state.count).to eq(1)
      end

      it "validates input" do
        state_class = Class.new(State::Base) do
          attribute :count, default: 1
          validate do
            required(:count).filled(:integer)
          end
        end
        state       = state_class.new(count: "2")
        expect(state.count).to eq(2)
      end
    end

    # it "mutates" do
    #   state     = State::Base.new({ count: 1 })
    #   new_state = state.mutate do |s|
    #     s.count = 2
    #   end
    #   expect(new_state.count).to eq(2)
    # end
  end

end