require "lucid/component/linking"

module Lucid
  describe Component::Linking do
    describe "#visit" do

      context "global link" do
        context "root component" do
          it "applies the destination state with a block" do
            link_class = Class.new(Link) do
              validate { required(:foo).filled(:string) }
            end
            app_class  = Class.new(Component::Base) do
              param :foo
              visit link_class, :foo
            end
            app        = app_class.new
            app.visit(link_class.new(foo: "bar"))
            expect(app.deep_state).to eq({ foo: "bar" })
          end

          it "applies the destination state with a symbol" do
            link_class = Class.new(Link) { validate { required(:foo).filled(:string) } }
            app_class  = Class.new(Component::Base) do
              param :foo
              visit link_class, :foo
            end
            app        = app_class.new
            app.visit(link_class.new(foo: "bar")).to_h
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
            called     = false
            link_class = Class.new(Link) do
              validate { required(:foo).filled(:string) }
            end
            app_class  = Class.new(Component::Base) do
              path :foo
              watch(:foo) { called = true }
              visit link_class, :foo
            end
            app        = app_class.new
            app.visit(link_class.new(foo: "bar"))
            expect(called).to be(true)
          end
        end

        context "nested component" do
          it "applies the nested state" do
            link_class = Class.new(Link) do
              validate do
                required(:foo).filled(:string)
                required(:baz).filled(:string)
              end
            end
            app_class  = Class.new(Component::Base) do
              param :foo
              visit link_class, :foo
              nest :bar do
                Class.new(Component::Base) {
                  param :baz
                  visit link_class, :baz
                }
              end
            end
            app        = app_class.new
            app.visit(link_class.new(foo: "bar", baz: "qux"))
            expect(app.deep_state).to eq({ foo: "bar", bar: { baz: "qux" } })
          end
        end
      end
    end
  end
end