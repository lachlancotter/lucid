module Lucid
  module Component
    describe ErrorHandling do

      # ===================================================== #
      #    Request Errors
      # ===================================================== #

      context "parameter error" do
        context "in self" do
          it "raises an exception" do
            component_class = Class.new(Component::Base) { param :foo, Types.string }
            expect { component_class.new({}) }.to raise_error(ParamError)
          end
        end

        context "in child component" do
          it "renders an error page" do
            child_component_class  = Class.new(Component::Base) { param :foo, Types.string }
            parent_component_class = Class.new(Component::Base) do
              nest(:child) { child_component_class }
              element { subview(:child) }
            end
            parent_component       = parent_component_class.new({})
            expect(parent_component.render_full).to match /Invalid Request/
          end
        end
      end

      context "permission error" do
        context "in self" do
          it "raises an exception" do
            component_class = Class.new(Component::Base) do
              def permitted?
                false
              end
            end
            expect { component_class.new({}) }.to raise_error(PermissionError)
          end
        end

        context "in a child component" do
          it "renders an error page" do
            child_component_class  = Class.new(Component::Base) do
              def permitted?
                false
              end
            end
            parent_component_class = Class.new(Component::Base) do
              nest(:child) { child_component_class }
              element { subview(:child) }
            end
            parent_component       = parent_component_class.new({})
            expect(parent_component.render_full).to match /Permission Denied/
          end
        end
      end

      # ===================================================== #
      #    Application Errors
      # ===================================================== #

      context "invalid props" do
        context "in self" do
          it "raises an error" do
            component_class = Class.new(Component::Base) { prop :foo, Types.string }
            expect { component_class.new({}) }.to raise_error(ConfigError)
          end
        end

        context "in a child component" do
          it "renders an error page" do
            child_component_class  = Class.new(Component::Base) { prop :foo, Types.string }
            parent_component_class = Class.new(Component::Base) do
              nest(:child) { child_component_class }
              element { subview(:child) }
            end
            parent_component       = parent_component_class.new({})
            expect(parent_component.render_full).to match /Invalid Config/
          end
        end

        context "in a child collection" do
          it "renders the other collection members" do
            child_component_class  = Class.new(Component::Base) do
              prop :count, Types.integer
              key { count.value }
              element do |count|
                h1 { text "Count #{count}" }
              end
            end
            parent_component_class = Class.new(Component::Base) do
              nest(:bars) { child_component_class.enum([1, 2, "foo", 4], as: :count) }
              element { subviews(:bars) }
            end
            parent_component       = parent_component_class.new({})
            expect(parent_component.render_full).to match /Count 1/
            expect(parent_component.render_full).to match /Count 2/
            expect(parent_component.render_full).to match /Count 3/
            expect(parent_component.render_full).to match /Count 4/
          end
        end
      end

      context "link error" do
        context "in self" do
          it "raises an error" do
            message_class   = Class.new(Link)
            component_class = Class.new(Component::Base) do
              param :foo, Types.integer.default(1)
              element { h1 { text "Success" } }
              to(message_class) { update(foo: "invalid") }
            end
            component       = component_class.new({})
            expect { component.visit(message_class.new) }.to raise_error(StateError)
          end
        end

        context "in a child component" do
          it "renders an error page" do
            message_class          = Class.new(Link)
            child_component_class  = Class.new(Component::Base) do
              param :foo, Types.integer.default(1)
              element { h1 { text "Success" } }
              to(message_class) { update(foo: "invalid") }
            end
            parent_component_class = Class.new(Component::Base) do
              nest(:child) { child_component_class }
              element { subview(:child) }
            end
            component              = parent_component_class.new({})
            component.visit(message_class.new)
            expect(component.render_full).to match /Invalid State/
          end
        end
      end

      context "event error" do
        context "in self" do
          it "raises an error" do
            message_class   = Class.new(Event)
            component_class = Class.new(Component::Base) do
              param :foo, Types.integer.default(1)
              element { h1 { text "Success" } }
              on(message_class) { update(foo: "invalid") }
            end
            component       = component_class.new({})
            expect { component.apply(message_class.new) }.to raise_error(StateError)
          end
        end

        context "in a child component" do
          it "renders an error page" do
            message_class          = Class.new(Event)
            child_component_class  = Class.new(Component::Base) do
              param :foo, Types.integer.default(1)
              element { h1 { text "Success" } }
              on(message_class) { update(foo: "invalid") }
            end
            parent_component_class = Class.new(Component::Base) do
              nest(:child) { child_component_class }
              element { subview(:child) }
            end
            component              = parent_component_class.new({})
            component.apply(message_class.new)
            expect(component.render_full).to match /Invalid State/
          end
        end
      end

      context "render error" do
        context "in self" do
          it "raises an exception" do
            component_class = Class.new(Component::Base) do
              let(:foo) { raise ResourceError.new(self, "foo") }
              element { |foo| h1 { text "No Error" } }
            end
            component       = component_class.new({})
            expect { component.render_full }.to raise_error(ResourceError)
          end
        end

        context "in child component" do
          it "renders an error page" do
            child_component_class  = Class.new(Component::Base) do
              element { raise ResourceError.new(self, "foo") }
            end
            parent_component_class = Class.new(Component::Base) do
              nest(:child) { child_component_class }
              element { subview(:child) }
            end
            parent_component       = parent_component_class.new({})
            expect(parent_component.render_full).to match /Resource Not Found/
          end
        end
      end

    end
  end
end