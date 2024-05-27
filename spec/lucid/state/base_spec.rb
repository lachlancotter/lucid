require "lucid/state/reader"

module Lucid
  describe State::Base do

    describe ".build" do
      context "defaults" do
        it "initializes default attribute values" do
          buffer          = State::Reader.new("/")
          component_class = Class.new(Component::Base) { param :foo, Types.string.default("bar") }
          component       = component_class.build(buffer)
          expect(component.state.to_h).to eq(foo: "bar")
        end
      end

      context "root component" do
        it "parses the URL" do
          buffer          = State::Reader.new("/foo/bar?baz=qux")
          component_class = Class.new(Component::Base) do
            path :foo
            path :bar
            param :baz
          end
          component       = component_class.build(buffer)
          expect(component.state.to_h).to eq(foo: "foo", bar: "bar", baz: "qux")
        end
      end

      context "nested component" do
        it "parses the URL" do
          buffer          = State::Reader.new("/foo/bar")
          component_class = Class.new(Component::Base) do
            path :foo
            nest :sub do
              Class.new(Component::Base) {
                path :bar
              }
            end
          end
          component       = component_class.build(buffer)
          expect(component.state.to_h).to eq(foo: "foo")
          expect(component.deep_state).to eq(foo: "foo", sub: { bar: "bar" })
          expect(component.sub.state.to_h).to eq(bar: "bar")
        end
      end
    end

    context "invalid" do
      it "raises an error" do
        state_class = Class.new(State::Base) do
          attribute :foo, Types.string
        end
        expect { state_class.new }.to raise_error(Dry::Types::CoercionError)
      end
    end

  end
end