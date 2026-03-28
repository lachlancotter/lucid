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
        expect(view.render).to match(
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
      
      context "with nested component" do
        it "renders the nested component" do
          nested_component_class = Class.new(Component::Base) do
            element { span { text "Nested Component" } }
          end
          base_component_class   = Class.new(Component::Base) do
            nest(:nested) { nested_component_class }
            element { subcomponent(:nested) }
          end

          view = base_component_class.new({})
          expect(view.template.render).to include("Nested Component")
        end
      end

      context "with named template" do
        it "renders the named template with template" do
          base_component_class = Class.new(Component::Base) do
            template(:greeting) do |name|
              span { text "Hello, #{name}" }
            end

            element { template(:greeting, "World") }
          end

          view = base_component_class.new({})
          expect(view.template.render).to include("<span>Hello, World</span>")
        end

        it "warns when fragment is used" do
          base_component_class = Class.new(Component::Base) do
            template(:greeting) do |name|
              span { text "Hello, #{name}" }
            end

            element { fragment(:greeting, "World") }
          end

          view = base_component_class.new({})
          expect { view.template.render }.
             to output(/`fragment` is deprecated; use `template` instead\./).to_stderr
        end
      end

      context "with nested component collection" do
        it "renders the collection with subcomponents" do
          nested_component_class = Class.new(Component::Base) do
            prop :name
            element { |name| span { text name } }
          end
          base_component_class   = Class.new(Component::Base) do
            nest(:nested) { nested_component_class[].enum(%w[One Two], as: :name) }
            element { subcomponents(:nested) }
          end

          view = base_component_class.new({})
          expect(view.template.render).to include("One")
          expect(view.template.render).to include("Two")
        end
      end

      context "invalid nested component name" do
        it "raises an exception" do
          base_component_class = Class.new(Component::Base) { element { subcomponent(:invalid_name) } }
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
