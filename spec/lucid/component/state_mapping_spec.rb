require "lucid/component/state_mapping"

module Lucid
  describe Component::StateMapping do
    
    describe ".url" do
      context "no path" do
        it "is the empty path" do
          view = Class.new(Component::Base) {}.new({})
          expect(view.url.to_s).to eq("/")
        end
      end

      it "maps params to query params" do
        component_class = Class.new(Component::Base) do
          param :foo, Types.string
          param :bar, Types.string
        end
        instance        = component_class.new({ foo: "first", bar: "second" })
        expect(instance.url).to eq("/?foo=first&bar=second")
      end

      it "omits default values" do
        component_class = Class.new(Component::Base) do
          param :foo, Types.string.default("first".freeze)
          param :bar, Types.string
        end
        instance        = component_class.new({ foo: "first", bar: "second" })
        expect(instance.url).to eq("/?bar=second")
      end

      it "maps params to path segments" do
        component_class = Class.new(Component::Base) do
          route ":foo/:bar"
          param :foo, Types.string
          param :bar, Types.string
        end
        instance        = component_class.new({ foo: "first", bar: "second" })
        expect(instance.url).to eq("/first/second")
      end

      it "maps string literals to path segments" do
        component_class = Class.new(Component::Base) do
          route "literal/:foo"
          param :foo, Types.string
        end
        instance        = component_class.new({ foo: "var" })
        expect(instance.url).to eq("/literal/var")
      end

      it "nests a subcomponent" do
        component_class = Class.new(Component::Base) do
          route ":foo", nest: :bar
          param :foo, Types.string
          nest :bar do
            Class.new(Component::Base) do
              route ":baz"
              param :baz, Types.string
            end
          end
          nest :not_on_path do
            Class.new(Component::Base) do
              route ":quox"
              param :quox, Types.string
            end
          end
        end
        state           = { bar: { baz: "baz" }, not_on_path: { quox: "quox" }, foo: "foo" }
        instance        = component_class.new(state)
        expect(instance.url).to eq("/foo/baz?quox.1=quox")
      end

      it "raises when segments are undefined" do
        component_class = Class.new(Component::Base) { route ":foo" }
        instance        = component_class.new({})
        expect { instance.url }.to raise_error(State::Writer::Error)
      end

      it "ignores leading and trailing slashes" do
        component_class = Class.new(Component::Base) do
          route "/:foo/:bar/"
          param :foo, Types.string
          param :bar, Types.string
        end
        instance        = component_class.new({ foo: "first", bar: "second" })
        expect(instance.url).to eq("/first/second")
      end
    end

    describe ".param" do
      it "defines query params" do
        component_class = Class.new(Component::Base) { param :foo }
        instance        = component_class.new({ foo: "bar" })
        expect(instance.state.foo).to eq("bar")
      end

      it "sets defaults" do
        component_class = Class.new(Component::Base) { param :count, Types.integer.default(1) }
        instance        = component_class.new({})
        expect(instance.state.count).to eq(1)
      end
    end

    describe "#update" do
      it "does not notify watchers or replace components for an unchanged value" do
        calls = 0
        message = Class.new(Event)
        child = Class.new(Component::Base) do
          prop :section
          element { |section| text section }
        end
        component = Class.new(Component::Base) do
          param :section, Types.string
          watch(:section) { calls += 1 }
          on(message) { update(section: "clients") }
          nest(:child) { child[section: :section] }
          element { text "Parent" }
        end.new({ section: "clients" }, message.new)

        expect(component.state.section).to eq("clients")
        expect(component.url).to eq("/?section=clients")
        expect(calls).to eq(0)
        expect(component.delta.replace?).to be(false)
        expect(component.child.delta.replace?).to be(false)
        expect(component.changes).to be_empty
      end

      it "notifies dependents and renders the affected component when a value changes" do
        calls = 0
        message = Class.new(Event)
        component = Class.new(Component::Base) do
          param :section, Types.string
          watch(:section) { calls += 1; replace }
          on(message) { update(section: "reports") }
          element { text "Parent" }
        end.new({ section: "clients" }, message.new)

        expect(component.state.section).to eq("reports")
        expect(calls).to eq(1)
        expect(component.changes.map(&:component)).to eq([component])
      end

      it "invalidates only changed fields in a mixed update" do
        calls = []
        message = Class.new(Event)
        component = Class.new(Component::Base) do
          param :section, Types.string
          param :drawer, Types.string
          watch(:section) { calls << :section }
          watch(:drawer) { calls << :drawer }
          on(message) { update(section: "clients", drawer: "open") }
        end.new({ section: "clients", drawer: "closed" }, message.new)

        expect(component.state.to_h).to eq(section: "clients", drawer: "open")
        expect(calls).to eq([:drawer])
      end

      it "compares URL values with typed incoming values" do
        calls = 0
        message = Class.new(Event)
        component = Class.new(Component::Base) do
          route ":count"
          param :count, Types.integer
          watch(:count) { calls += 1 }
          on(message) { update(count: 3) }
          element { text "Count" }
        end.new({ count: "3" }, message.new)

        expect(component.state.count).to eq(3)
        expect(component.url).to eq("/3")
        expect(calls).to eq(0)
        expect(component.changes).to be_empty
      end

      it "caches typed URL values before deferred validation" do
        message = Class.new(Event)
        component = Class.new(Component::Base) do
          param :count, Types.integer
          let(:doubled) { |count| count * 2 }

          on(message) do
            doubled
            update(count: 3)
          end
        end.new({ count: "3" }, message.new)

        expect(component.state.count).to eq(3)
        expect(component.count).to eq(3)
        expect(component.doubled).to eq(6)
      end

      it "allows a message to fix invalid pending URL state" do
        message = Class.new(Event)
        component = Class.new(Component::Base) do
          param :count, Types.integer
          on(message) { update(count: 3) }
        end.new({ count: "invalid" }, message.new)

        expect(component.state.count).to eq(3)
      end

      it "retains validation errors for invalid pending values" do
        message = Class.new(Event)
        component_class = Class.new(Component::Base) do
          param :count, Types.integer
          on(message) { update(count: "invalid") }
        end

        expect { component_class.new({ count: "invalid" }, message.new) }.to raise_error(ParamError)
      end

      it "still allows explicit replace and invalidate to force refreshes" do
        replace_message = Class.new(Event)
        invalidate_message = Class.new(Event)
        component_class = Class.new(Component::Base) do
          param :section, Types.string
          on(replace_message) { update(section: "clients"); replace }
          on(invalidate_message) { update(section: "clients"); invalidate :section }
          element { |section| text section }
        end

        [replace_message, invalidate_message].each do |message|
          component = component_class.new({ section: "clients" }, message.new)
          expect(component.changes.map(&:component)).to eq([component])
        end
      end

      it "changes only the drawer when a broad parent link keeps its section" do
        section_link = Class.new(Link) do
          validate { required(:section).filled(:string) }
        end
        drawer_link = Class.new(section_link) do
          validate do
            required(:section).filled(:string)
            required(:drawer).filled(:string)
          end
        end
        child = Class.new(Component::Base) do
          param :drawer, Types.string.default("closed".freeze)
          to(drawer_link, :drawer)
          element { |drawer| text drawer }
        end
        parent = Class.new(Component::Base) do
          param :section, Types.string
          to(section_link, :section)
          watch(:section) { replace }
          nest(:drawer) { child }
          element { text "Parent" }
        end

        [
          [{ section: "clients" }, "open"],
          [State::Store.from_url("/?section=clients&drawer.0=open"), "closed"],
          [State::Store.from_url("/?section=clients&drawer.0=open"), "other"]
        ].each do |state, drawer_value|
          changed = parent.new(state, drawer_link.new(section: "clients", drawer: drawer_value))
          expect(changed.changes.map(&:component)).to eq([changed.drawer])
          expect(changed.delta.replace?).to be(false)
        end

        navigated = parent.new({ section: "clients" }, section_link.new(section: "reports"))
        expect(navigated.changes.map(&:component)).to eq([navigated])
      end
    end

    describe "validation" do
      context "valid data" do
        it "constructs the component" do
          component_class = Class.new(Component::Base) do
            param :count, Types.integer
          end
          expect { component_class.new({ count: "1" }) }.not_to raise_error
        end
      end

      context "invalid data" do
        it "raises en error" do
          component_class = Class.new(Component::Base) do
            param :count, Types.integer
          end
          expect { component_class.new({ count: "foo" }) }.to raise_error(ParamError)
        end
      end
    end

  end
end
