require "lucid/template"

module Lucid
  describe Template do
    context "static" do
      it "renders with Papercraft" do
        view = Class.new(View).new
        template = Template.new(view) do
          div { text "Hello, World" }
        end
        expect(template.render).to eq("<div>Hello, World</div>")
      end
    end

    context "with state" do
      it "renders the state" do
        view = Class.new(View) do
          state { attribute :name }
        end.new(name: "World")

        template = Template.new(view) do
          div { text "Hello, #{state.name}" }
        end
        expect(template.render).to eq("<div>Hello, World</div>")
      end
    end
  end
end
