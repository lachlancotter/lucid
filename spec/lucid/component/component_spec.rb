require "lucid/component/base"

module Lucid
  describe Component::Base do

    # ===================================================== #
    #    Templates
    # ===================================================== #

    describe ".element" do
      context "main template" do
        it "renders the main template" do
          view = Class.new(Component::Base) do
            param :name
            element { div { text "Hello, #{state[:name]}" } }
          end.new({ name: "World" })
          expect(view.render_full).to eq("<div>Hello, World</div>")
        end
      end
    end

    # ===================================================== #
    #    Rendering
    # ===================================================== #

    describe "#render" do
      it "renders the view" do
        view = Class.new(Component::Base) do
          def render
            "Hello, World"
          end
        end.new({})
        expect(view.render).to eq("Hello, World")
      end
    end

  end
end



