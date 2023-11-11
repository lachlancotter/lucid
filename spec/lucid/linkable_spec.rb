module Lucid
  describe Linkable do
    describe "#visit" do
      context "root Linkable" do
        it "applies the destination state" do
          app_class = Class.new(Component) do
            visit Link do |link, state|
              state[:foo] = link[:foo]
            end
          end
          app       = app_class.new
          state     = app.visit(Link.new(foo: "bar")).to_h
          expect(state).to eq({ foo: "bar" })
        end
      end

      context "nested Linkable" do
        it "applies the nested state" do
          app_class = Class.new(Component) do
            visit Link do |link, state|
              state[:foo] = link[:foo]
            end
            nest :bar, Class.new(Component) do
              visit Link do |link, state|
                state[:baz] = link[:baz]
              end
            end
          end
          app       = app_class.new
          state     = app.visit(Link.new(foo: "bar", baz: "qux")).to_h
          expect(state).to eq({ foo: "bar", bar: { baz: "qux" } })
        end
      end

      context "two nested Linkables" do
        it "applies the nested state" do

        end
      end

      context "deep nested Linkable" do
        it "applies deeply nested states" do

        end
      end
    end
  end

  describe Link::Local do
    describe "#href" do
      it "encodes params" do
        app_class = Class.new(Component) do
          route { path :count }
          visit :set_count do |link, state|
            state[:count] = link[:count]
          end
        end
        app       = app_class.new(count: 1)
        link      = app.link(:set_count, count: 2)
        expect(link.href).to eq("/2")
      end

      it "encodes state" do
        app_class = Class.new(Component) do
          route { path :count }
          visit :inc do |link, state|
            state[:count] += 1
          end
        end
        app       = app_class.new(count: 1)
        link      = app.link(:inc)
        expect(link.href).to eq("/2")
      end
    end
  end

  describe Link do
    describe "#href" do
      it "encodes params" do
        app_class = Class.new(Component) do
          route { path :id }
          visit Link do |link, state|
            state[:id] = link[:id]
          end
        end
        app       = app_class.new(id: 1)
        link      = Link.new(id: 2)
        Link.with_context(app) do
          expect(link.href).to eq("/2")
        end
      end

      it "encodes state" do
        app_class = Class.new(Component) do
          route { path :page, :id }
          visit Link do |link, state|
            state[:id] = link[:id]
          end
        end
        app       = app_class.new(page: "foo")
        link      = Link.new(id: 1)
        Link.with_context(app) do
          expect(link.href).to eq("/foo/1")
        end
      end
    end
  end
end