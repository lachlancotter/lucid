require "lucid/component/base"
require "lucid/location"

module Lucid
  describe Component::Base do

    # ===================================================== #
    #    State
    # ===================================================== #

    # describe ".state" do
    #   it "defines attributes" do
    #     view = Class.new(Component::Base) do
    #       state do
    #         attribute :foo
    #       end
    #     end.new
    #     expect(view.state).to have_attributes(foo: nil)
    #   end
    #
    #   it "sets defaults" do
    #     view = Class.new(Component::Base) do
    #       state do
    #         attribute :foo, default: "bar"
    #       end
    #     end.new
    #     expect(view.state).to have_attributes(foo: "bar")
    #   end
    # end

    # describe "validation" do
    #   context "valid state" do
    #     it "coerces the input" do
    #       view = Class.new(Component::Base) do
    #         state do
    #           attribute :count
    #           validate do
    #             required(:count).filled(:integer)
    #           end
    #         end
    #       end.new(count: "1")
    #       expect(view.state.count).to eq(1)
    #     end
    #   end
    #
    #   context "invalid state" do
    #
    #   end
    # end

    # ===================================================== #
    #    Templates
    # ===================================================== #

    describe ".template" do
      context "main template" do
        it "renders the main template" do
          view = Class.new(Component::Base) do
            param :name
            template { div { text "Hello, #{state.name}" } }
          end.new(name: "World")
          expect(view.template.render).to eq("<div>Hello, World</div>")
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
        end.new
        expect(view.render).to eq("Hello, World")
      end
    end

  end
end



