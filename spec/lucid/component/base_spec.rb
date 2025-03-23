module Lucid
  module Component
    describe Base do

      describe ".new" do
        context "defaults" do
          it "initializes default attribute values" do
            buffer          = State::Reader.new("/")
            component_class = Class.new(Component::Base) { param :foo, Types.string.default("bar".freeze) }
            component       = component_class.new(buffer)
            expect(component.state.to_h).to eq(foo: "bar")
          end
        end

        context "root component" do
          it "parses the URL" do
            buffer          = State::Reader.new("/foo/bar?baz=qux")
            component_class = Class.new(Component::Base) do
              route "/:foo/:bar"
              param :foo
              param :bar
              param :baz
            end
            component       = component_class.new(buffer)
            expect(component.state.to_h).to eq(foo: "foo", bar: "bar", baz: "qux")
          end
        end

        context "nested component" do
          it "parses the URL" do
            buffer          = State::Reader.new("/foo/bar")
            component_class = Class.new(Component::Base) do
              route "/:foo", nest: :sub
              param :foo, Types.string
              nest :sub do
                Class.new(Component::Base) {
                  route "/:bar"
                  param :bar
                }
              end
            end
            component       = component_class.new(buffer)
            expect(component.state.to_h).to eq(foo: "foo")
            expect(component.deep_state).to eq(foo: "foo", sub: { bar: "bar" })
            expect(component.sub.state.to_h).to eq(bar: "bar")
          end
        end
      end

      describe "#element_id" do
        it "includes the path" do
          view_class = Class.new(Component::Base) do
            nest :foo do
              Class.new(Component::Base) do
                nest(:bar) { Class.new(Component::Base) }
              end
            end
          end
          view       = view_class.new({})
          expect(view.foo.bar.element_id).to eq("foo-bar")
        end
      end

    end
  end
end