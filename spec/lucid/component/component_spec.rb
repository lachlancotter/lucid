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
            element { |name| div { text "Hello, #{name}" } }
          end.new({ name: "World" })
          expect(view.render).to eq("<div>Hello, World</div>")
        end
      end
    end

    # ===================================================== #
    #    Rendering
    # ===================================================== #

    describe "#render" do
      it "renders the main component HTML by default" do
        view = Class.new(Component::Base) do
          param :name
          element { |name| div { text "Hello, #{name}" } }
        end.new({ name: "World" })
        expect(view.render).to eq("<div>Hello, World</div>")
      end

      it "renders the view" do
        view = Class.new(Component::Base) do
          def render
            "Hello, World"
          end
        end.new({})
        expect(view.render).to eq("Hello, World")
      end

      it "warns when render_full is used" do
        view = Class.new(Component::Base) do
          element { div { text "Hello, World" } }
        end.new({})

        expect { view.render_full }.
           to output(/`render_full` is deprecated; use `render` instead\./).to_stderr
      end
    end

  end
end


