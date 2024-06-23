require "lucid/template"

module Lucid
  describe Template do
    context "static" do
      it "renders with Papercraft" do
        view     = Class.new(Component::Base).new({})
        template = Template.new do
          div { text "Hello, World" }
        end.bind(view)
        expect(template.render).to eq("<div>Hello, World</div>")
      end
    end

    it "renders script elements" do
      view = Class.new(Component::Base) do
        element do
          head {
            script(src: "https://example.com/script.js")
          }
        end
      end.new({})
      view.element.replace
      expect(view.render_full).to match(
         '<head><script src="https://example.com/script.js"></script></head>'
      )
    end

    context "with template arguments" do
      it "renders the template" do
        view     = Class.new(Component::Base)
        template = Template.new do |name|
          div { text "Hello, #{name}" }
        end.bind(view)
        expect(template.render("World")).to eq("<div>Hello, World</div>")
      end
    end

    context "with state" do
      it "renders the state" do
        view = Class.new(Component::Base) do
          param :name
        end.new({ name: "World" })

        template = Template.new do
          div { text "Hello, #{state[:name]}" }
        end.bind(view)
        expect(template.render).to eq("<div>Hello, World</div>")
      end
    end
  end
end
