module Lucid
  describe Rendering do
    describe "render" do
      describe "template" do
        it "renders" do
          view = Class.new(Component::Base) do
            element { h1 { text "Hello, World" } }
          end.new({})
          view.element.replace
          expect(view.render_full).to match(/<h1>Hello, World<\/h1>/)
        end
      end

      describe "element ID" do
        context "root component" do
          it "is omitted" do
            view = Class.new(Component::Base) do
              element { h1 { text "Hello, World" } }
            end.new({})
            view.element.replace
            expect(view.render_full).to eq("<h1>Hello, World</h1>")
          end
        end

        context "nested component" do
          it "is the component path" do
            view = Class.new(Component::Base) do
              nest :foo do
                Class.new(Component::Base) {
                  element { h1 { text "Nested" } }
                }
              end
              element { subview(:foo) }
            end.new({})
            view.element.replace
            expect(view.render_full).to match(/<div id="foo"><h1>Nested<\/h1><\/div>/)
          end
        end
      end

      describe "template with args" do
        it "renders" do
          view = Class.new(Component::Base) do
            param :name
            element do |name|
              h1 { text "Hello, #{name}" }
            end
          end.new({})
          expect(view.template.render("World")).to match(/<h1>Hello, World<\/h1>/)
        end
      end

      describe "template with context" do
        it "renders" do
          view = Class.new(Component::Base) do
            element do
              h1 { text "Hello, #{name}" }
            end

            def name
              "World"
            end
          end.new({})
          expect(view.render_full).to match(/<h1>Hello, World<\/h1>/)
        end
      end

      describe "context with name collision" do
        it "renders" do
          view = Class.new(Component::Base) do
            element do
              h1 { text "Hello, #{context.label}" }
            end

            def label
              "World"
            end
          end.new({})
          expect(view.render_full).to match(/<h1>Hello, World<\/h1>/)
        end
      end
    end
  end
end