require "lucid/component/referable"

module Lucid
  describe Component::Referable do
    describe ".href" do
      it "returns the location" do
        view = Class.new(Component::Base) do
          href { path :foo }
          state do
            attribute :foo, default: "bar"
          end
        end.new
        expect(view.href.to_s).to eq("/bar")
      end
    end
  end
end