module Lucid
  module RSpec
    module Components

      describe ComponentFormatter do
        it "renders a component" do
          component_class = Class.new(Component::Base) do
            element do
              h1 { text "Hello, World" }
            end
          end
          component       = component_class.new({})
          formatter       = ComponentFormatter.new(component)
          expect(formatter.to_s).to include("Hello, World")
        end
        
        it "includes link HREFs" do
          component_class = Class.new(Component::Base) do
            element do
              link_to "https://example.com", "Example"
            end
          end
          component       = component_class.new({})
          formatter       = ComponentFormatter.new(component)
          expect(formatter.to_s).to include("https://example.com")
        end

        it "formats links as messages" do
          class TestLink < Lucid::Link
            validate do
              required(:foo).filled(:string)
            end
          end

          component_class = Class.new(Component::Base) do
            element do
              link_to TestLink.new(foo: "bar"), "Example"
            end
          end
          component       = component_class.new({})
          formatter       = ComponentFormatter.new(component)
          expect(formatter.to_s).to include("TestLink(foo: 'bar')")
        end

        it "formats form actions as messages" do
          class TestFormCommand < Lucid::Command
            validate do
              required(:foo).filled(:string)
            end
          end

          form_model      = Lucid::HTTP::FormModel.new(TestFormCommand, { foo: "bar" })
          component_class = Class.new(Component::Base) do
            element do
              form_for form_model do |f|
                f.text(:foo)
              end
            end
          end
          component       = component_class.new({})
          formatter       = ComponentFormatter.new(component)
          expect(formatter.to_s).to include("TestFormCommand")
        end

        it "formats form input values" do
          class TestFormCommand < Lucid::Command
            validate do
              required(:foo).filled(:string)
            end
          end

          form_model      = Lucid::HTTP::FormModel.new(TestFormCommand, { foo: "bar" })
          component_class = Class.new(Component::Base) do
            element do
              form_for form_model do |f|
                f.text(:foo)
              end
            end
          end
          component       = component_class.new({})
          formatter       = ComponentFormatter.new(component)
          expect(formatter.to_s).to include("[foo: 'bar']")
        end

        it "formats form textarea values" do
          class TestFormCommand < Lucid::Command
            validate do
              required(:foo).filled(:string)
            end
          end

          form_model      = Lucid::HTTP::FormModel.new(TestFormCommand, { foo: "bar" })
          component_class = Class.new(Component::Base) do
            element do
              form_for form_model do |f|
                f.textarea(:foo)
              end
            end
          end
          component       = component_class.new({})
          formatter       = ComponentFormatter.new(component)
          expect(formatter.to_s).to include("[foo: 'bar']")
        end

        it "formats form select values" do
          class TestFormCommand < Lucid::Command
            validate do
              required(:foo).filled(:string)
            end
          end

          form_model      = Lucid::HTTP::FormModel.new(TestFormCommand, { foo: "bar" })
          component_class = Class.new(Component::Base) do
            element do
              form_for form_model do |f|
                f.select(:foo) do |s|
                  s.option("bar", "Bar")
                  s.option("baz", "Baz")
                end
              end
            end
          end
          component       = component_class.new({})
          formatter       = ComponentFormatter.new(component)
          expect(formatter.to_s).to include("[foo: 'bar']")
        end

        it "includes form ACTION and METHOD" do
          component_class = Class.new(Component::Base) do
            element do
              form(action: "/submit", method: "post") do
                button(type: "submit") { text "Send" }
              end
            end
          end
          component       = component_class.new({})
          formatter       = ComponentFormatter.new(component)
          expect(formatter.to_s).to include("/submit")
          expect(formatter.to_s).to include("post")
        end

        it "separates block elements with empty lines" do
          component_class = Class.new(Component::Base) do
            element do
              p { text "First" }
              p { text "Second" }
            end
          end
          component       = component_class.new({})
          formatter       = ComponentFormatter.new(component)
          expect(formatter.to_s).to eq("First\n\nSecond")
        end

        it "places inputs on new lines" do
          component_class = Class.new(Component::Base) do
            element do
              form(action: "/submit", method: "post") do
                input(type: "text", name: "foo", value: "a")
                input(type: "text", name: "bar", value: "b")
              end
            end
          end
          component       = component_class.new({})
          formatter       = ComponentFormatter.new(component)
          expect(formatter.to_s).to include("[foo: 'a']\n[bar: 'b']")
        end

        it "keeps inline elements on the same line" do
          component_class = Class.new(Component::Base) do
            element do
              p do
                text "Hello, "
                span { text "World" }
              end
            end
          end
          component       = component_class.new({})
          formatter       = ComponentFormatter.new(component)
          expect(formatter.to_s).to include("Hello, World")
        end
        
        it "collapses multiple empty lines" do
          component_class = Class.new(Component::Base) do
            element do
              div { p { text "First" } }
              div { p { text "Second" } }
            end
          end
          component       = component_class.new({})
          formatter       = ComponentFormatter.new(component)
          expect(formatter.to_s).not_to include("\n\n\n")
        end

        it "represents nested components with indentation" do
          class TestChild < Component::Base
            element do
              p { text "Child content" }
            end
          end

          component_class = Class.new(Component::Base) do
            nest(:child) { TestChild }
            element do
              h1 { text "Parent" }
              subview :child
            end
          end
          component       = component_class.new({})
          formatter       = ComponentFormatter.new(component)
          expect(formatter.to_s).to include("---")
          expect(formatter.to_s).to include("TestChild")
          expect(formatter.to_s).to include("  Child content")
        end

        it "filters HTML tags" do
          component_class = Class.new(Component::Base) do
            element do
              h1 { text "Hello, World" }
            end
          end
          component       = component_class.new({})
          formatter       = ComponentFormatter.new(component)
          expect(formatter.to_s).not_to include("<h1>")
        end
      end

    end
  end
end