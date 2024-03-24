module Lucid
  module HTTP
    describe MessageName do
      describe ".encode" do
        it "converts class names to URLs" do
          expect(MessageName.encode(Lucid::Component::Base)).to eq("lucid/component/base")
        end
      end

      describe ".decode" do
        it "converts URLs class names" do
          expect(MessageName.decode("lucid/component/base")).to eq("Lucid::Component::Base")
        end
      end
    end
  end
end