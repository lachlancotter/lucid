module Lucid
  describe Rendering do
    describe "render" do
      describe "default template" do
        it "renders" do
          view = Class.new(Component::Base) do
            template do
              h1 { text "Hello, World" }
            end
          end.new
          view.element.replace
          expect(view.render).to match(/<h1>Hello, World<\/h1>/)
        end
      end

      describe "named template" do
        it "renders" do
          view = Class.new(Component::Base) do
            template :foo do
              h1 { text "Hello, World" }
            end
          end.new
          expect(view.template(:foo).render).to match(/<h1>Hello, World<\/h1>/)
        end
      end

      describe "element ID" do
        context "root component" do
          it "is omitted" do
            view = Class.new(Component::Base) do
              template do
                h1 { text "Hello, World" }
              end
            end.new
            view.element.replace
            expect(view.render).to eq("<h1>Hello, World</h1>")
          end
        end

        context "nested component" do
          it "is the component path" do
            view = Class.new(Component::Base) do
              nest :foo, Class.new(Component::Base) {
                template { h1 { text "Nested" } }
              }
              template { subview(:foo) }
            end.new
            view.element.replace
            expect(view.render).to match(/<div id="foo"><h1>Nested<\/h1><\/div>/)
          end
        end
      end

      describe "template with args" do
        it "renders" do
          view = Class.new(Component::Base) do
            param :name
            template do |name|
              h1 { text "Hello, #{name}" }
            end
          end.new
          expect(view.template.render("World")).to match(/<h1>Hello, World<\/h1>/)
        end
      end

      describe "template with context" do
        it "renders" do
          view = Class.new(Component::Base) do
            template do
              h1 { text "Hello, #{name}" }
            end

            def name
              "World"
            end
          end.new
          view.element.replace
          expect(view.render).to match(/<h1>Hello, World<\/h1>/)
        end
      end

      describe "context with name collision" do
        it "renders" do
          view = Class.new(Component::Base) do
            template do
              h1 { text "Hello, #{context.label}" }
            end

            def label
              "World"
            end
          end.new
          view.element.replace
          expect(view.render).to match(/<h1>Hello, World<\/h1>/)
        end
      end
    end
  end
end