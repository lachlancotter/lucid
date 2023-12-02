module Lucid
  describe State::Base do

    context "invalid" do
      it "raises an error" do
        state_class = Class.new(State::Base) do
          validate do
            required(:foo).filled(:string)
          end
        end
        expect { state_class.new }.to raise_error(State::Invalid)
      end
    end

  end
end