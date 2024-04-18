module Lucid
  module Component
    describe Base do

      describe "#element_id" do
        it "includes the path" do
          view_class = Class.new(Component::Base) do
            nest :foo, Class.new(Component::Base) {
              nest :bar, Class.new(Component::Base) {}
            }
          end
          view       = view_class.new
          expect(view.foo.bar.element_id).to eq("foo-bar")
        end
      end

    end
  end
end