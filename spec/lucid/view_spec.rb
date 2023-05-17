require "lucid/view"

module Lucid
  describe View do

    describe ".link" do
      it 'defines a link' do
        view = Class.new(View) do
          link :foo
        end.new
        expect(view.foo).to be_a(Link)
      end
    end

    describe "#to_s" do
      it "renders the view" do
        view = Class.new(View) do
          def render
            "Hello, World"
          end
        end.new
        expect(view.to_s).to eq("Hello, World")
      end
    end

  end
end



