module Lucid
  module Component
    describe Title do

      it "defaults to an 'Untitled'" do
        component_class = Class.new(Component::Base) {}
        component       = component_class.new({})
        expect(component.title).to eq("Untitled")
      end

      it "returns the block value" do
        component_class = Class.new(Component::Base) do
          title { "Title" }
        end
        component       = component_class.new({})
        expect(component.title).to eq("Title")
      end

      it "accepts signal arguments" do
        component_class = Class.new(Component::Base) do
          param :name, Types.string
          title { |name| "Hello, #{name}" }
        end
        component       = component_class.new({ name: "World" })
        expect(component.title).to eq("Hello, World")
      end

      it "includes a nested title" do
        nested_component_class = Class.new(Component::Base) do
          title { "Nested" }
        end
        base_component_class   = Class.new(Component::Base) do
          route "/base", nest: :nested_component
          nest(:nested_component) { nested_component_class }
          title { "Base: #{nested_title}" }
        end
        component = base_component_class.new({})
        expect(component.title).to eq("Base: Nested")
      end

    end
  end
end