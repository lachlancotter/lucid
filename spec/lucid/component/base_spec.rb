module Lucid
  module Component
    describe Base do

      describe "#element_id" do
        it "includes the path" do
          view_class = Class.new(Component::Base) do
            nest :foo do
              Class.new(Component::Base) do
                nest(:bar) { Class.new(Component::Base) }
              end
            end
          end
          view       = view_class.new
          expect(view.foo.bar.element_id).to eq("foo-bar")
        end
      end

    end
  end
end