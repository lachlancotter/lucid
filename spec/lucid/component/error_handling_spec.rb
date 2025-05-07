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
          component = component_class.new({})
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
          component = component_class.new({})
          expect(component.valid?).to be_truthy
          expect(component.permitted?).to be_falsey
          expect(component.denied?).to be_truthy
          expect(component.error).to be_a(PermissionError)
          expect(component.render_full).to match /Permission Denied/
        end
      end

      context "let returns resource error" do
        it "enters an error state" do
          component_class = Class.new(Component::Base) do
            let(:foo) { ResourceError.new(self, "foo") }
            element { |foo| h1 { text "Success" } }
            template(ResourceError) { h1 { text "Resource Missing" } }
          end
          component = component_class.new({})
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
          component = component_class.new({})
          expect(component.valid?).to be_truthy
          expect(component.permitted?).to be_truthy
          expect(component.render_full).to match /Resource Missing/
          expect(component.error).to be_a(ResourceError)
        end
      end

      context "props error" do
        it "enters an error state" do
          component_class = Class.new(Component::Base) do
            prop :foo, Types.string
          end
          component = component_class.new({})
          expect(component.valid?).to be_falsey
          expect(component.invalid?).to be_truthy
          expect(component.error).to be_a(ConfigError)
        end
      end

      context "update error" do
        it "enters an error state" do
          message_class = Class.new(Link)
          component_class = Class.new(Component::Base) do
            param :foo, Types.integer.default(1)
            element { h1 { text "Success" } }
            template(StateError) { h1 { text "Invalid State" } }
            to(message_class) { update(foo: "invalid") }
          end
          component = component_class.new({})
          component.visit(message_class.new)
          expect(component.valid?).to be_falsey
          expect(component.render_full).to match /Invalid State/
        end
      end

      context "template error" do
        it "enters an error state" do
          
        end
      end
      
    end
  end
end