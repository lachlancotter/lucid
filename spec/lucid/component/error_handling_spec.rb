module Lucid
  module Component
    describe ErrorHandling do

      # ===================================================== #
      #    Request Errors
      # ===================================================== #

      context "parameter error" do
        it "enters an error state" do
          component_class = Class.new(Component::Base) do
            param :foo, Types.string
            template ParamError do
              h1 { text "Invalid Request" }
            end
          end
          component       = component_class.new({})
          expect(component.valid?).to be_falsey
          expect(component.invalid?).to be_truthy
          expect(component.error).to be_a(ParamError)
          expect(component.render_full).to match /Invalid Request/
        end
      end

      context "permission error" do
        it "enters an error state" do
          component_class = Class.new(Component::Base) do
            guard { Deny }
            template PermissionError do
              h1 { text "Permission Denied" }
            end
          end
          component       = component_class.new({})
          expect(component.valid?).to be_truthy
          expect(component.permitted?).to be_falsey
          expect(component.denied?).to be_truthy
          expect(component.error).to be_a(PermissionError)
          expect(component.render_full).to match /Permission Denied/
        end
      end

      context "props error" do
        it "enters an error state" do
          component_class = Class.new(Component::Base) do
            prop :foo, Types.string
          end
          component       = component_class.new({})
          expect(component.valid?).to be_falsey
          expect(component.invalid?).to be_truthy
          expect(component.error).to be_a(ConfigError)
        end
      end

      context "update error" do
        it "enters an error state" do
          message_class   = Class.new(Link)
          component_class = Class.new(Component::Base) do
            param :foo, Types.integer.default(1)
            element { h1 { text "Success" } }
            template(StateError) { h1 { text "Invalid State" } }
            to(message_class) { update(foo: "invalid") }
          end
          component       = component_class.new({})
          component.visit(message_class.new)
          expect(component.valid?).to be_falsey
          expect(component.render_full).to match /Invalid State/
        end
      end

      context "error subclass" do
        it "inherits the template of the error superclass" do
          error_class     = Class.new(ApplicationError)
          component_class = Class.new(Component::Base) do
            let(:foo) { error_class.new }
            template(ApplicationError) { h1 { text "App Error" } }
            element { |foo| text "Default" }
          end
          component       = component_class.new({})
          expect(component.render_full).to match /App Error/
        end
      end

      context "component subclass" do
        it "inherits error templates from the component superclass" do
          error_class          = Class.new(ApplicationError)
          component_superclass = Class.new(Component::Base) do
            template(error_class) { h1 { text "Error Template" } }
          end
          component_class      = Class.new(component_superclass) do
            let(:foo) { error_class.new }
            element { |foo| text "Default" }
          end
          component            = component_class.new({})
          expect(component.render_full).to match /Error Template/
        end
      end

      context "unknown error" do
        it "renders the default error template" do
          component_class = Class.new(Component::Base) do
            let(:foo) { StandardError.new }
            element { |foo| text "Default" }
          end
          ap component_class.templates
          ap component_class.superclass.templates
          component =   component_class.new({})
          expect(component.render_full).to match /Unknown Error/
        end
      end

      context "let returns resource error" do
        it "enters an error state" do
          component_class = Class.new(Component::Base) do
            let(:foo) { ResourceError.new(self, "foo") }
            element { |foo| h1 { text "Success" } }
            template(ResourceError) { h1 { text "Resource Missing" } }
          end
          component       = component_class.new({})
          expect(component.valid?).to be_truthy
          expect(component.permitted?).to be_truthy
          expect(component.render_full).to match /Resource Missing/
          expect(component.error).to be_a(ResourceError)
        end
      end

      context "let raises resource error" do
        it "enters an error state" do
          component_class = Class.new(Component::Base) do
            let(:foo) { raise ResourceError.new(self, "foo") }
            element { |foo| h1 { text "Success" } }
            template(ResourceError) { h1 { text "Resource Missing" } }
          end
          component       = component_class.new({})
          expect(component.valid?).to be_truthy
          expect(component.permitted?).to be_truthy
          expect(component.render_full).to match /Resource Missing/
          expect(component.error).to be_a(ResourceError)
        end
      end

      context "template error" do
        it "enters an error state" do

        end
      end

    end
  end
end