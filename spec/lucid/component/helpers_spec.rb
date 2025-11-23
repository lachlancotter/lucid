module Lucid
  module Component
    describe Helpers do

      context "regular method" do
        let(:component_class) do
          Class.new(Component::Base) do
            def greet(name)
              "Hello, #{name}!"
            end

            element do
              text greet("Bob")
            end
          end
        end
        it "is handled by the template engine" do
          component = component_class.new({})
          expect(component.template.render).to include("<greet>")
        end
      end

      describe ".helper" do
        context "with a block" do
          let(:component_class) do
            Class.new(Component::Base) do
              helper :greet do |name|
                "Hello, #{name}!"
              end

              element do
                text greet("Bob")
              end
            end
          end

          it "defines a helper method" do
            component = component_class.new({})
            expect(component.greet("Alice")).to eq("Hello, Alice!")
          end

          it "is available in the template" do
            component = component_class.new({})
            expect(component.template.render).to eq("Hello, Bob!")
          end
        end

        context "without a block" do
          let(:component_class) do
            Class.new(Component::Base) do
              helper :greet

              def greet(name)
                "Hello, #{name}!"
              end

              element do
                text greet("Bob")
              end
            end
          end
          
          it "marks a helper method" do
            component = component_class.new({})
            expect(component.greet("Alice")).to eq("Hello, Alice!")
          end

          it "is available in the template" do
            component = component_class.new({})
            expect(component.template.render).to eq("Hello, Bob!")
          end
        end
      end

    end
  end
end