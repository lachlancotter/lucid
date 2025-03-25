module Lucid
  module Component
    describe Rendering do
      describe "#template" do
        context "no template defined" do
          it "returns an empty template" do
            view = Class.new(Component::Base).new({})
            expect(view.template.render).to eq("Base")
          end
        end

        context "base template defined" do
          it "returns the base template" do
            view = Class.new(Component::Base) do
              element { h1 { text "Hello, World" } }
            end.new({})
            expect(view.template.render).to match(/<h1>Hello, World<\/h1>/)
          end
        end

        context "named template" do
          it "returns the named template" do
            view = Class.new(Component::Base) do
              template(:foo) { h1 { text "Foo Template" } }
            end.new({})
            expect(view.template(:foo).render).to match(/<h1>Foo Template<\/h1>/)
          end
        end

        context "undefined template" do
          it "raises an exception" do
            view = Class.new(Component::Base).new({})
            expect { view.template(:foo) }.to raise_error(Templating::TemplateNotFound)
          end
        end
      end

      describe "#render_full" do
        it "renders" do
          view = Class.new(Component::Base) do
            element { h1 { text "Hello, World" } }
          end.new({})
          view.delta.replace
          expect(view.render_full).to match(/<h1>Hello, World<\/h1>/)
        end
      end

      describe "render" do
        describe "element ID" do
          context "root component" do
            it "is omitted" do
              view = Class.new(Component::Base) do
                element { h1 { text "Hello, World" } }
              end.new({})
              view.delta.replace
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
              view.delta.replace
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
end