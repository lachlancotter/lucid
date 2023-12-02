require "lucid/component/linkable"

module Lucid
  describe Component::Linkable do
    describe "#visit" do

      context "global link" do
        context "root component" do
          it "applies the destination state" do
            app_class = Class.new(Component::Base) do
              visit Link do |link|
                state.update(foo: link[:foo])
              end
            end
            app       = app_class.new
            app.visit(Link.new(foo: "bar")).to_h
            expect(app.deep_state).to eq({ foo: "bar" })
          end
        end

        context "nested component" do
          it "applies the nested state" do
            app_class = Class.new(Component::Base) do
              visit Link do |link|
                state.update(foo: link[:foo])
              end
              nest :bar do
                visit Link do |link|
                  state.update(baz: link[:baz])
                end
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
              visit :set_count do |link|
                state.update(count: link[:count])
              end
            end
            app       = app_class.new(count: 1)
            app.visit(app.link(:set_count, count: 2))
            expect(app.deep_state).to eq({ count: 2 })
          end
        end

        context "nested component" do
          it "applies the nested state" do
            app_class = Class.new(Component::Base) do
              nest :foo do
                visit :set_count do |link|
                  state.update(count: link[:count])
                end
              end
            end
            app       = app_class.new
            link      = app.nested(:foo).link(:set_count, count: 2)
            app.visit(link)
            expect(app.deep_state).to eq({ foo: { count: 2 } })
          end
        end
      end
    end
  end

  describe Link do
    describe "#href" do
      it "encodes params" do
        app_class = Class.new(Component::Base) do
          href { path :id }
          visit Link do |link|
            state.update(id: link[:id])
          end
        end
        app       = app_class.new(id: 1)
        link      = Link.new(id: 2)
        Message.with_context(app) do
          expect(Message.context).not_to be_nil
          expect(link.href.to_s).to eq("/1?msgn=Lucid-Link&msga[id]=2")
        end
      end

      it "encodes state" do
        app_class = Class.new(Component::Base) do
          href { path :page, :id }
          visit Link do |link|
            state.update(id: link[:id])
          end
        end
        app       = app_class.new(page: "foo")
        link      = Link.new(id: 1)
        Message.with_context(app) do
          expect(link.href.to_s).to eq("/foo/?msgn=Lucid-Link&msga[id]=1")
        end
      end
    end
  end
end