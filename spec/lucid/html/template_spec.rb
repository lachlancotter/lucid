require "lucid/html/template"

module Lucid
  module HTML
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
        view.delta.replace
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

      context "with nested component" do
        it "renders the nested component" do
          nested_component_class = Class.new(Component::Base) do
            element { span { text "Nested Component" } }
          end
          base_component_class   = Class.new(Component::Base) do
            nest(:nested) { nested_component_class }
            element { subview(:nested) }
          end

          view = base_component_class.new({})
          expect(view.template.render).to include("Nested Component")
        end
      end

      context "invalid nested component name" do
        it "raises an exception" do
          base_component_class = Class.new(Component::Base) { element { subview(:invalid_name) } }
          view                 = base_component_class.new({})
          expect { view.template.render }.to raise_error(ApplicationError)
        end
      end

      context "command passed to link_to" do
        it "raises an exception" do
          msg_class = Class.new(Lucid::Command)
          view      = Class.new(Component::Base) do
            element { link_to msg_class.new, "Link" }
          end.new({})
          expect { view.template.render }.to raise_error(ApplicationError)
        end
      end
    end
  end
end