require "lucid/state/scope"
require "lucid/state/store"

module Lucid
  module State
    describe Scope do

      describe "#initialize" do
        it "creates a scope with default depth and coordinate" do
          store = Store.new
          scope = Scope.new(store)
          expect(scope).to be_a(Scope)
        end

        it "creates a scope with custom depth" do
          store = Store.new
          scope = Scope.new(store, 2)
          expect(scope).to be_a(Scope)
        end

        it "creates a scope with custom coordinate" do
          store = Store.new
          scope = Scope.new(store, 0, [1, 2, 3])
          expect(scope).to be_a(Scope)
        end

        it "defaults to empty coordinate array" do
          store = Store.new
          scope = Scope.new(store, 0)
          expect(scope).to be_a(Scope)
        end
      end

      describe "#get_segment" do
        it "returns the segment at depth + n" do
          store = Store.new(["a", "b", "c", "d"])
          scope = Scope.new(store, 0)
          expect(scope.get_segment(0)).to eq("a")
          expect(scope.get_segment(1)).to eq("b")
        end

        it "offsets the index by depth" do
          store = Store.new(["a", "b", "c", "d"])
          scope = Scope.new(store, 2)
          expect(scope.get_segment(0)).to eq("c")
          expect(scope.get_segment(1)).to eq("d")
        end

        it "returns nil when index is out of range" do
          store = Store.new(["a", "b"])
          scope = Scope.new(store, 0)
          expect(scope.get_segment(5)).to be_nil
        end

        it "handles nil segments in the path" do
          store = Store.new(["a", nil, "c"])
          scope = Scope.new(store, 0)
          expect(scope.get_segment(1)).to be_nil
        end
      end

      describe "#set_segment" do
        it "sets the segment at depth + n" do
          store = Store.new(["a", "b", "c"])
          scope = Scope.new(store, 0)
          scope.set_segment(1, "changed")
          expect(store.get_segment(1)).to eq("changed")
        end

        it "offsets the index by depth" do
          store = Store.new(["a", "b", "c", "d"])
          scope = Scope.new(store, 2)
          scope.set_segment(0, "changed")
          expect(store.get_segment(2)).to eq("changed")
        end

        it "expands the path array if necessary" do
          store = Store.new(["a", "b"])
          scope = Scope.new(store, 0)
          scope.set_segment(3, "new")
          expect(store.get_segment(3)).to eq("new")
        end

        it "can set segments to nil" do
          store = Store.new(["a", "b", "c"])
          scope = Scope.new(store, 0)
          scope.set_segment(1, nil)
          expect(store.get_segment(1)).to be_nil
        end
      end

      describe "#get_param" do
        it "returns the parameter value" do
          store = Store.new([], { "foo" => "bar" })
          scope = Scope.new(store)
          expect(scope.get_param("foo")).to eq("bar")
        end

        it "qualifies the parameter key with coordinate" do
          store = Store.new([], { "foo.123" => "bar" })
          scope = Scope.new(store, 0, [1, 2, 3])
          expect(scope.get_param("foo")).to eq("bar")
        end

        it "returns nil for non-existent parameters" do
          store = Store.new
          scope = Scope.new(store)
          expect(scope.get_param("missing")).to be_nil
        end

        it "does not qualify when coordinate is empty" do
          store = Store.new([], { "foo" => "bar" })
          scope = Scope.new(store, 0, [])
          expect(scope.get_param("foo")).to eq("bar")
        end

        it "handles multi-digit coordinates" do
          store = Store.new([], { "foo.10203" => "bar" })
          scope = Scope.new(store, 0, [1, 0, 2, 0, 3])
          expect(scope.get_param("foo")).to eq("bar")
        end
      end

      describe "#set_param" do
        it "sets the parameter value" do
          store = Store.new
          scope = Scope.new(store)
          scope.set_param("foo", "bar")
          expect(store.get_param("foo")).to eq("bar")
        end

        it "qualifies the parameter key with coordinate" do
          store = Store.new
          scope = Scope.new(store, 0, [1, 2, 3])
          scope.set_param("foo", "bar")
          expect(store.get_param("foo.123")).to eq("bar")
        end

        it "does not qualify when coordinate is empty" do
          store = Store.new
          scope = Scope.new(store, 0, [])
          scope.set_param("foo", "bar")
          expect(store.get_param("foo")).to eq("bar")
        end

        it "handles multi-digit coordinates" do
          store = Store.new
          scope = Scope.new(store, 0, [1, 0, 2, 0, 3])
          scope.set_param("foo", "bar")
          expect(store.get_param("foo.10203")).to eq("bar")
        end

        it "can overwrite existing parameters" do
          store = Store.new([], { "foo" => "old" })
          scope = Scope.new(store)
          scope.set_param("foo", "new")
          expect(store.get_param("foo")).to eq("new")
        end
      end

      describe "#descend" do
        it "returns a new scope with the same store" do
          store = Store.new(["a", "b", "c"])
          scope1 = Scope.new(store, 0)
          scope2 = scope1.descend(1, 0)
          
          expect(scope2).to be_a(Scope)
          expect(scope2).not_to eq(scope1)
        end

        it "combines depths additively" do
          store = Store.new(["a", "b", "c", "d", "e"])
          scope1 = Scope.new(store, 1)
          scope2 = scope1.descend(2, 0)
          
          # scope1 has depth 1, so get_segment(0) returns "b"
          expect(scope1.get_segment(0)).to eq("b")
          
          # scope2 has combined depth 3, so get_segment(0) returns "d"
          expect(scope2.get_segment(0)).to eq("d")
        end

        it "appends to the coordinate array" do
          store = Store.new([], { "foo.123" => "bar" })
          scope1 = Scope.new(store, 0, [1, 2])
          scope2 = scope1.descend(0, 3)
          
          expect(scope2.get_param("foo")).to eq("bar")
        end

        it "combines depth and coordinate" do
          store = Store.new(["a", "b", "c"], { "key.01" => "value" })
          scope1 = Scope.new(store, 0, [0])
          scope2 = scope1.descend(1, 1)
          
          expect(scope2.get_segment(0)).to eq("b")
          expect(scope2.get_param("key")).to eq("value")
        end

        it "allows descending from a scope that already has depth and coordinate" do
          store = Store.new(["a", "b", "c", "d"], { "x.012" => "value" })
          scope1 = Scope.new(store, 1, [0, 1])
          scope2 = scope1.descend(1, 2)
          
          # scope1: depth=1, coordinate=[0, 1]
          expect(scope1.get_segment(0)).to eq("b")
          
          # scope2: depth=2 (1+1), coordinate=[0, 1, 2]
          expect(scope2.get_segment(0)).to eq("c")
          expect(scope2.get_param("x")).to eq("value")
        end

        it "shares the underlying store" do
          store = Store.new(["a", "b", "c"])
          scope1 = Scope.new(store, 0)
          scope2 = scope1.descend(1, 0)
          
          scope2.set_segment(0, "changed")
          
          # Both scopes see the change because they share the store
          expect(store.get_segment(1)).to eq("changed")
          expect(scope1.get_segment(1)).to eq("changed")
        end

        it "allows descending with zero depth offset" do
          store = Store.new(["a", "b"], { "foo.12" => "bar" })
          scope1 = Scope.new(store, 1, [1])
          scope2 = scope1.descend(0, 2)
          
          # Same depth as scope1, but extended coordinate
          expect(scope2.get_segment(0)).to eq("b")
          expect(scope2.get_param("foo")).to eq("bar")
        end

        it "builds up nested coordinates" do
          store = Store.new([], { "key.0123" => "value" })
          scope1 = Scope.new(store, 0, [])
          scope2 = scope1.descend(0, 0)
          scope3 = scope2.descend(0, 1)
          scope4 = scope3.descend(0, 2)
          scope5 = scope4.descend(0, 3)
          
          expect(scope5.get_param("key")).to eq("value")
        end
      end

      describe "combined depth and coordinate" do
        it "applies both depth offset and coordinate" do
          store = Store.new(["a", "b", "c"], { "foo.12" => "bar" })
          scope = Scope.new(store, 1, [1, 2])

          expect(scope.get_segment(0)).to eq("b")
          expect(scope.get_segment(1)).to eq("c")
          expect(scope.get_param("foo")).to eq("bar")
        end

        it "maintains isolation from other scopes" do
          store  = Store.new(["a", "b", "c"], { "key1" => "value1", "key2.01" => "value2" })
          scope1 = Scope.new(store, 0, [])
          scope2 = Scope.new(store, 1, [0, 1])

          expect(scope1.get_segment(0)).to eq("a")
          expect(scope1.get_param("key1")).to eq("value1")

          expect(scope2.get_segment(0)).to eq("b")
          expect(scope2.get_param("key2")).to eq("value2")
        end

        it "allows multiple scopes to modify the same store" do
          store  = Store.new(["a", "b", "c"])
          scope1 = Scope.new(store, 0)
          scope2 = Scope.new(store, 1)

          scope1.set_segment(0, "changed_a")
          scope2.set_segment(0, "changed_b")

          expect(store.get_segment(0)).to eq("changed_a")
          expect(store.get_segment(1)).to eq("changed_b")
        end
      end

    end
  end
end
