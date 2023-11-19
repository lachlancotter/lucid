module Lucid
  describe App::Cycle do
    describe ".visit" do
      context "single component" do
        it "returns the new state tree" do
          link_class = Class.new(Link)
          base_class = Class.new(Component) do
            visit link_class do |state, link|
              state.update(count: 1)
            end
          end
          cycle      = App::Cycle.new(base_class, { app_root: "/" }, "/")
          state      = cycle.visit(link_class.new).to_h
          expect(state).to eq({ count: 1 })
        end
      end

      context "nested component" do
        it "returns the new state tree" do
          link_class = Class.new(Link)
          base_class = Class.new(Component) do
            visit link_class do |state, link|
              state.update(foo: "bar")
            end
            nest :sub, Class.new(Component) do
              visit link_class do |state, link|
                state.update(baz: "qux")
              end
            end
          end
          cycle      = App::Cycle.new(base_class, { app_root: "/" }, "/")
          state      = cycle.visit(link_class.new).to_h
          expect(state).to eq({ foo: "bar", sub: { baz: "qux" } })
        end
      end
    end
  end
end