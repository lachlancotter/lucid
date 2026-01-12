require "lucid/state/map"
require "lucid/state/writer"

module Lucid
  module State
    describe Writer do
      context "empty state" do
        it "returns the root path" do
          data   = {}
          map    = Map.build {}
          writer = Writer.new
          store  = Store.new
          writer.with_scope(store.scoped) do 
            writer.write_state(map, data)
          end
          expect(store.to_url).to eq("/")
        end
      end

      context "single path component" do
        it "sets the hash key" do
          data   = { foo: "foo" }
          map    = Map.build { path :foo }
          store  = Store.new
          writer = Writer.new
          writer.with_scope(store.scoped) do 
            writer.write_state(map, data)
          end
          expect(store.to_url).to eq("/foo")
        end
      end

      context "multiple path components" do
        it "sets the hash keys" do
          data   = { foo: "foo", bar: "bar" }
          writer = Writer.new
          map    = Map.build { path :foo; path :bar }
          store  = Store.new
          writer.with_scope(store.scoped) do 
            writer.write_state(map, data)
          end
          expect(store.to_url).to eq("/foo/bar")
        end
      end

      context "literal path components" do
        it "adds literals to the path" do
          data   = { foo: "foo" }
          writer = Writer.new
          map    = Map.build { path "lit"; path :foo }
          store  = Store.new
          writer.with_scope(store.scoped) do 
            writer.write_state(map, data)
          end
          expect(store.to_url).to eq("/lit/foo")
        end
      end

      context "single query param" do
        it "sets the hash key" do
          data   = { foo: "bar" }
          writer = Writer.new
          map    = Map.build { query :foo }
          store  = Store.new
          writer.with_scope(store.scoped) do 
            writer.write_state(map, data)
          end
          expect(store.to_url).to eq("/?foo=bar")
        end
      end

      context "multiple query params" do
        it "sets the hash keys" do
          data   = { foo: "bar", baz: "qux" }
          writer = Writer.new
          map    = Map.build { query :foo; query :baz }
          store  = Store.new
          writer.with_scope(store.scoped) do 
            writer.write_state(map, data)
          end
          expect(store.to_url).to eq("/?foo=bar&baz=qux")
        end
      end

      context "mixed parameter types" do
        it "reads path and query params" do
          data   = { foo: "foo", bar: "baz" }
          writer = Writer.new
          map    = Map.build { path :foo; query :bar }
          store  = Store.new
          writer.with_scope(store.scoped) do 
            writer.write_state(map, data)
          end
          expect(store.to_url).to eq("/foo?bar=baz")
        end
      end

      context "nested query params" do
        it "builds the nested structure" do
          data   = { foo: { bar: "baz" } }
          nested = Map.build { query :bar }
          writer = Writer.new
          store  = Store.new
          writer.with_scope(store.scoped.descend(0, 0)) do
            writer.write_state(nested, data[:foo])
          end
          expect(store.to_url).to eq("/?bar.0=baz")
        end
      end

      context "multiple nested maps" do
        it "builds the nested structure" do
          data    = { foo: { bar: "baz" }, qux: { duck: "corge" } }
          writer  = Writer.new
          foo_map = Map.build { query :bar }
          qux_map = Map.build { query :duck }
          store   = Store.new
          writer.with_scope(store.scoped.descend(0, 0)) do
            writer.write_state(foo_map, data[:foo])  
          end
          writer.with_scope(store.scoped.descend(0, 1)) do
            writer.write_state(qux_map, data[:qux])
          end
          expect(store.to_url).to eq("/?bar.0=baz&duck.1=corge")
        end
      end

      context "multiple nested path maps" do
        it "maps segments from the first nest" do
          data    = { foo: { bar: "baz" }, qux: { kiln: "corge" } }
          writer  = Writer.new
          foo_map = Map.build { path :bar }
          qux_map = Map.build { path :kiln; path "literal" }
          store = Store.new
          writer.with_scope(store.scoped.descend(0, 0)) do
            writer.write_state foo_map, data[:foo]
          end
          writer.with_scope(store.scoped.descend(0, 1)) do
            writer.write_state qux_map.off_route, data[:qux]
          end
          expect(store.to_url).to eq("/baz?kiln.1=corge")
        end
      end
    end
  end
end