require "lucid/component/linking"

module Lucid
  describe Component::Linking do
    describe "#to" do

      context "global link" do
        context "root component" do
          it "applies the destination state with a block" do
            link_class = Class.new(Link) do
              validate { required(:foo).filled(:string) }
            end
            app_class  = Class.new(Component::Base) do
              param :foo
              to link_class, :foo
            end
            link       = link_class.new(foo: "bar")
            app        = app_class.new({}, link)
            expect(app.deep_state).to eq({ foo: "bar" })
          end

          it "applies the destination state with a symbol" do
            link_class = Class.new(Link) { validate { required(:foo).filled(:string) } }
            app_class  = Class.new(Component::Base) do
              param :foo
              to link_class, :foo
            end
            link       = link_class.new(foo: "bar")
            app        = app_class.new({}, link)
            expect(app.deep_state).to eq({ foo: "bar" })
          end

          it "applies the destination state with a Hash" do
            app_class = Class.new(Component::Base) do
              param :foo
              to Link, foo: "bar"
            end
            app       = app_class.new({}, Link.new)
            expect(app.deep_state).to eq({ foo: "bar" })
          end

          it "triggers watchers" do
            called     = false
            link_class = Class.new(Link) do
              validate { required(:foo).filled(:string) }
            end
            app_class  = Class.new(Component::Base) do
              param :foo
              watch(:foo) { called = true }
              to link_class, :foo
            end
            link       = link_class.new(foo: "bar")
            app        = app_class.new({}, link)
            expect(called).to be(true)
          end

          it "applies link params before validating required state" do
            link_class = Class.new(Link) do
              validate { required(:foo).filled(:string) }
            end
            app_class  = Class.new(Component::Base) do
              param :foo, Types.string
              to link_class, :foo
            end
            link       = link_class.new(foo: "bar")
            app        = app_class.new({}, link)
            expect(app.deep_state).to eq({ foo: "bar" })
          end

          it "raises when the applied link does not satisfy required state" do
            app_class = Class.new(Component::Base) do
              param :foo, Types.string
              to Link
            end
            expect { app_class.new({}, Link.new) }.to raise_error(ParamError)
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
              to link_class, :foo
              nest :bar do
                Class.new(Component::Base) {
                  param :baz
                  to link_class, :baz
                }
              end
            end
            link       = link_class.new(foo: "bar", baz: "qux")
            app        = app_class.new({}, link)
            expect(app.deep_state).to eq({ foo: "bar", bar: { baz: "qux" } })
          end

          it "applies link params before validating required child state" do
            link_class = Class.new(Link) do
              validate { required(:baz).filled(:string) }
            end
            app_class  = Class.new(Component::Base) do
              nest :bar do
                Class.new(Component::Base) {
                  param :baz, Types.string
                  to link_class, :baz
                }
              end
            end
            link       = link_class.new(baz: "qux")
            app        = app_class.new({}, link)
            expect(app.deep_state).to eq({ bar: { baz: "qux" } })
          end

          it "renders a param error when the applied link does not satisfy required child state" do
            child_class = Class.new(Component::Base) do
              param :baz, Types.string
              to Link
            end
            app_class   = Class.new(Component::Base) do
              nest(:bar) { child_class }
              element { subcomponent(:bar) }
            end
            app         = app_class.new({}, Link.new)
            expect(app.render).to match /Invalid Request/
          end

          it "applies a link to a child selected by the parent link state before validating the child" do
            link_class = Class.new(Link) do
              validate { required(:id).filled(:string) }
            end
            child_class = Class.new(Component::Base) do
              param :id, Types.string
              to link_class, :id
            end
            empty_class = Class.new(Component::Base)
            app_class   = Class.new(Component::Base) do
              param :mode, Types.string.default("empty".freeze)
              to link_class, mode: "child"
              nest :panel do
                mode == "child" ? child_class : empty_class
              end
            end
            link        = link_class.new(id: "123")
            app         = app_class.new({}, link)
            expect(app.deep_state).to eq({ mode: "child", panel: { id: "123" } })
          end
        end
      end
    end

    context "invalid message type" do
      it "raises an exception" do
        event_class = Class.new(Event)
        expect {
          Class.new(Component::Base) { to(event_class) {} }
        }.to raise_error(ApplicationError)
      end
    end
  end
end
