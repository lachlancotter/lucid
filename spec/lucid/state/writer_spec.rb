require "lucid/state/map"
require "lucid/state/writer"

module Lucid
  module State
    describe Writer do
      context "empty state" do
        it "returns the root path" do
          data   = {}
          map    = Map.build {}
          writer = Writer.new(data)
          writer.write_state(map)
          expect(writer.to_s).to eq("/")
        end
      end

      context "single path component" do
        it "sets the hash key" do
          data   = { foo: "foo" }
          map    = Map.build { path :foo }
          writer = Writer.new(data)
          writer.write_state(map)
          expect(writer.to_s).to eq("/foo")
        end
      end

      context "multiple path components" do
        it "sets the hash keys" do
          data   = { foo: "foo", bar: "bar" }
          writer = Writer.new(data)
          map    = Map.build { path :foo; path :bar }
          writer.write_state(map)
          expect(writer.to_s).to eq("/foo/bar")
        end
      end

      context "literal path components" do
        it "adds literals to the path" do
          data   = { foo: "foo" }
          writer = Writer.new(data)
          map    = Map.build { path "lit"; path :foo }
          writer.write_state(map)
          expect(writer.to_s).to eq("/lit/foo")
        end
      end

      context "single query param" do
        it "sets the hash key" do
          data   = { foo: "bar" }
          writer = Writer.new(data)
          map    = Map.build { query :foo }
          writer.write_state(map)
          expect(writer.to_s).to eq("/?foo=bar")
        end
      end

      context "multiple query params" do
        it "sets the hash keys" do
          data   = { foo: "bar", baz: "qux" }
          writer = Writer.new(data)
          map    = Map.build { query :foo; query :baz }
          writer.write_state(map)
          expect(writer.to_s).to eq("/?foo=bar&baz=qux")
        end
      end

      context "mixed parameter types" do
        it "reads path and query params" do
          data   = { foo: "foo", bar: "baz" }
          writer = Writer.new(data)
          map    = Map.build { path :foo; query :bar }
          writer.write_state(map)
          expect(writer.to_s).to eq("/foo?bar=baz")
        end
      end

      context "nested query params" do
        it "builds the nested structure" do
          data   = { foo: { bar: "baz" } }
          nested = Map.build { query :bar }
          writer = Writer.new(data)
          writer.with_scope(:foo) do
            writer.write_state(nested)
          end
          expect(writer.to_s).to eq("/?foo%5Bbar%5D=baz")
        end
      end

      context "multiple nested maps" do
        it "builds the nested structure" do
          data    = { foo: { bar: "baz" }, qux: { duck: "corge" } }
          writer  = Writer.new(data)
          foo_map = Map.build { query :bar }
          qux_map = Map.build { query :duck }
          top_map = Map.build { query :foo }
          writer.write_state(top_map)
          writer.with_scope(:foo) { writer.write_state(foo_map) }
          writer.with_scope(:qux) { writer.write_state(qux_map) }
          expect(writer.to_s).to eq("/?foo%5Bbar%5D=baz&qux%5Bduck%5D=corge")
        end
      end

      context "multiple nested path maps" do
        it "maps segments from the first nest" do
          data    = { foo: { bar: "baz" }, qux: { kiln: "corge" } }
          writer  = Writer.new(data)
          foo_map = Map.build { path :bar }
          qux_map = Map.build { path :kiln ; path "literal" }
          writer.with_scope(:foo) { writer.write_state foo_map }
          writer.with_scope(:qux) { writer.write_state qux_map.off_route }
          expect(writer.to_s).to eq("/baz?qux%5Bkiln%5D=corge")
        end
      end

      context "nested collection", skip: true do
        it "maps collection elements" do
          data = { foo: [{ bar: "baz" }, { bar: "qux" }] }
          writer = Writer.new(data)
          map = Map.build { query :bar }
          writer.with_scope(:foo) do
            writer.write_collection(map)
          end
        end
      end
    end
  end
end