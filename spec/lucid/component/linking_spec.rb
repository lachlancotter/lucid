require "lucid/component/linking"

module Lucid
  describe Component::Linking do
    describe "#visit" do

      context "global link" do
        context "root component" do
          it "applies the destination state with a block" do
            app_class = Class.new(Component::Base) do
              param :foo
              visit Link, :foo
            end
            app       = app_class.new
            app.visit(Link.new(foo: "bar"))
            expect(app.deep_state).to eq({ foo: "bar" })
          end

          it "applies the destination state with a symbol" do
            app_class = Class.new(Component::Base) do
              param :foo
              visit Link, :foo
            end
            app       = app_class.new
            app.visit(Link.new(foo: "bar")).to_h
            expect(app.deep_state).to eq({ foo: "bar" })
          end

          it "applies the destination state with a Hash" do
            app_class = Class.new(Component::Base) do
              param :foo
              visit Link, foo: "bar"
            end
            app       = app_class.new
            app.visit(Link.new)
            expect(app.deep_state).to eq({ foo: "bar" })
          end

          it "triggers watchers" do
            called    = false
            app_class = Class.new(Component::Base) do
              path :foo
              watch(:foo) { called = true }
              visit Link, :foo
            end
            app       = app_class.new
            app.visit(Link.new(foo: "bar"))
            expect(called).to be(true)
          end
        end

        context "nested component" do
          it "applies the nested state" do
            app_class = Class.new(Component::Base) do
              param :foo
              visit Link, :foo
              nest :bar do
                Class.new(Component::Base) {
                  param :baz
                  visit Link, :baz
                }
              end
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
              param :count, Types.integer.default(0)
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
              nest :foo do
                Class.new(Component::Base) {
                  param :count, Types.integer.default(0)
                  visit :set_count, :count
                }
              end
            end
            app       = app_class.new
            link      = app.send(:foo).link_to(:set_count, count: 2)
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
          path :id, Types.integer
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