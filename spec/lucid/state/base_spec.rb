module Lucid
  describe State::Base do

    describe ".build" do
      context "root component" do
        it "parses the URL" do
          buffer = Location::ReadBuffer.new("/foo/bar?baz=qux")
          component_class = Class.new(Component::Base) do
            href do
              path :foo
              path :bar
              param :baz
            end
          end
          component = component_class.build(buffer)
          expect(component.state.to_h).to eq(foo: "foo", bar: "bar", baz: "qux")
        end
      end

      context "nested component" do
        it "parses the URL" do
          buffer = Location::ReadBuffer.new("/foo/bar")
          component_class = Class.new(Component::Base) do
            href do
              path :foo
              nest :sub
            end
            nest :sub, Class.new(Component::Base) {
              href do
                path :bar
              end
            }
          end
          component = component_class.build(buffer)
          expect(component.state.to_h).to eq(foo: "foo", sub: { bar: "bar" })
        end
      end
    end

    context "invalid" do
      it "raises an error" do
        state_class = Class.new(State::Base) do
          validate do
            required(:foo).filled(:string)
          end
        end
        expect { state_class.new }.to raise_error(State::Invalid)
      end
    end

  end
end