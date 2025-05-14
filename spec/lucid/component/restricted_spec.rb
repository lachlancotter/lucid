module Lucid
  module Component
    describe Restricted do

      context "unrestricted component" do
        it "can render" do
          component_class = Class.new(Component::Base) { element { text "Permitted" } }
          component       = component_class.new({})
          expect(component.render_full).to match("Permitted")
        end
      end

      context "policy permits view" do
        it "can render" do
          policy_class    = Class.new(Policy) do
            def permits_view? (resource)
              true
            end
          end
          component_class = Class.new(Component::Base) do
            adopt policy_class, :resource
            let(:resource) { "foo" }
            element { text "Permitted" }
          end
          component       = component_class.new({})
          expect(component.render_full).to match("Permitted")
        end
      end

      context "policy denies view" do
        it "raises an exception" do
          policy_class    = Class.new(Policy) do
            def permits_view? (resource)
              false
            end
          end
          component_class = Class.new(Component::Base) do
            adopt policy_class, :resource
            let(:resource) { "foo" }
            element { text "Permitted" }
          end
          expect { component_class.new({}) }.to raise_error(PermissionError)
        end
      end

    end
  end
end