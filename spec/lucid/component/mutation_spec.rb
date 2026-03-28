module Lucid
  module Component
    describe Mutation do
      describe "#set" do
        it "updates state-backed fields" do
          msg_class  = Class.new(Lucid::Event)
          view_class = Class.new(Component::Base) do
            param :foo
            on(msg_class) { set(foo: "bar") }
          end

          view = view_class.new({}, msg_class.new)
          expect(view.foo).to eq("bar")
        end

        it "updates temp-backed fields" do
          msg_class  = Class.new(Lucid::Event)
          view_class = Class.new(Component::Base) do
            temp :foo
            on(msg_class) { set(foo: "bar") }
          end

          view = view_class.new({}, msg_class.new)
          expect(view.foo).to eq("bar")
        end

        it "updates state-backed and temp-backed fields together" do
          msg_class  = Class.new(Lucid::Event)
          view_class = Class.new(Component::Base) do
            param :page, Types.integer.default(0)
            temp :loading, Types.bool.default(false)
            on(msg_class) { set(page: 1, loading: true) }
          end

          view = view_class.new({}, msg_class.new)
          expect(view.page).to eq(1)
          expect(view.loading).to eq(true)
        end

        it "raises on unknown writable signals" do
          msg_class  = Class.new(Lucid::Event)
          view_class = Class.new(Component::Base) do
            on(msg_class) { set(foo: "bar") }
          end

          expect { view_class.new({}, msg_class.new) }.
             to raise_error(ArgumentError, /Unknown writable signals: foo/)
        end
      end
    end
  end
end
