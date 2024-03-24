require "lucid/component/linkable"

module Lucid
  describe Component::Linkable do
    describe "#visit" do

      context "global link" do
        context "root component" do
          it "applies the destination state with a block" do
            app_class = Class.new(Component::Base) do
              visit Link, :foo
            end
            app       = app_class.new
            app.visit(Link.new(foo: "bar"))
            expect(app.deep_state).to eq({ foo: "bar" })
          end

          it "applies the destination state with a symbol" do
            app_class = Class.new(Component::Base) do
              visit Link, :foo
            end
            app       = app_class.new
            app.visit(Link.new(foo: "bar")).to_h
            expect(app.deep_state).to eq({ foo: "bar" })
          end

          it "applies the destination state with a Hash" do
            app_class = Class.new(Component::Base) do
              visit Link, foo: "bar"
            end
            app       = app_class.new
            app.visit(Link.new)
            expect(app.deep_state).to eq({ foo: "bar" })
          end
        end

        context "nested component" do
          it "applies the nested state" do
            app_class = Class.new(Component::Base) do
              visit Link, :foo
              nest :bar, Class.new(Component::Base) {
                visit Link, :baz
              }
            end
            app       = app_class.new
            app.visit(Link.new(foo: "bar", baz: "qux"))
            expect(app.deep_state).to eq({ foo: "bar", bar: { baz: "qux" } })
          end
        end
      end

      describe "scoped link" do
        context "root component" do
          it "applies the destination state" do
            app_class = Class.new(Component::Base) do
              visit :set_count, :count
            end
            app       = app_class.new(count: 1)
            app.visit(app.link_to(:set_count, count: 2))
            expect(app.deep_state).to eq({ count: 2 })
          end
        end

        context "nested component" do
          it "applies the nested state" do
            app_class = Class.new(Component::Base) do
              nest :foo, Class.new(Component::Base) {
                visit :set_count, :count
              }
            end
            app       = app_class.new
            link      = app.nested(:foo).link_to(:set_count, count: 2)
            app.visit(link)
            expect(app.deep_state).to eq({ foo: { count: 2 } })
          end
        end
      end
    end
  end

  describe Link do
    class TestLink < Link

    end

    describe "#href" do
      it "encodes state" do
        app_class = Class.new(Component::Base) do
          path :id
          visit TestLink, :id
        end
        app       = app_class.new(id: 1)
        link      = TestLink.new(id: 2)
        Message.with_context(app) do
          expect(link.href.to_s).to eq("/@/lucid/test-link?id=2&state[id]=1")
        end
      end
    end
  end
end