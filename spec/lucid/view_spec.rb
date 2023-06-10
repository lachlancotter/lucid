require "lucid/view"
require "lucid/route"

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

    describe "#routes" do
      it "returns the route map" do
        view = Class.new(View) do
          route { path :foo }
        end.new
        expect(view.routes).to be_a(Route::Map)
        expect(view.routes.rules.first).to be_a(Route::Map::Path)
        expect(view.routes.rules.first.key).to eq(:foo)
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



