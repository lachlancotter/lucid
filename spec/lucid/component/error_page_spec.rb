module Lucid
  module Component
    describe ErrorPage do

      context "error subclass" do
        it "inherits the template of the error superclass" do
          error_class     = Class.new(ApplicationError)
          component_class = Class.new(ErrorPage) do
            let(:foo) { error_class.new }
            template(ApplicationError) { h1 { text "App Error" } }
            element { |foo| text "Default" }
          end
          component       = component_class.new({}, error: error_class.new)
          expect(component.render_full).to match /App Error/
        end
      end

      context "component subclass" do
        it "inherits error templates from the component superclass" do
          error_class     = Class.new(ApplicationError)
          component_class = Class.new(ErrorPage) do
            let(:foo) { error_class.new }
            element { |foo| text "Default" }
          end
          component       = component_class.new({}, error: error_class.new)
          expect(component.render_full).to match /Unknown Error/
        end
      end

      context "unknown error" do
        it "renders the default error template" do
          component_class = Class.new(ErrorPage) do
            let(:foo) { StandardError.new }
            element { |foo| text "Default" }
          end
          component       = component_class.new({}, error: StandardError.new)
          expect(component.render_full).to match /Unknown Error/
        end
      end

    end
  end
end