require "lucid/state/map"
require "lucid/state/reader"
require "lucid/state/writer"
require "lucid/state/namespace"

module Lucid
  module State
    describe Reader do
      context "empty query" do
        it "returns an empty hash" do
          reader = Reader.new("/").cursor
          map    = Map.build {}
          data   = reader.read(map)
          expect(data).to eq({})
        end
      end

      context "single path component" do
        it "sets the hash key" do
          reader = Reader.new("/foo").cursor
          map    = Map.build { path :foo }
          data   = reader.read(map)
          expect(data).to eq(foo: "foo")
        end
      end

      context "multiple path components" do
        it "sets the hash keys" do
          reader = Reader.new("/foo/bar").cursor
          map    = Map.build { path :foo; path :bar }
          data   = reader.read(map)
          expect(data).to eq(foo: "foo", bar: "bar")
        end
      end

      context "literal path components" do
        it "skips literals" do
          reader = Reader.new("/lit/foo").cursor
          map    = Map.build { path "lit"; path :foo }
          data   = reader.read(map)
          expect(data).to eq(foo: "foo")
        end
      end

      context "literal component mismatch" do
        it "raises an error" do
          reader = Reader.new("/foo/bar").cursor
          map    = Map.build { path "baz"; path :bar }
          expect { reader.read(map) }.to raise_error(Map::MismatchedPath)
        end
      end

      context "single query param" do
        it "sets the hash key" do
          reader = Reader.new("?foo=bar").cursor
          map    = Map.build { query :foo }
          data   = reader.read(map)
          expect(data).to eq(foo: "bar")
        end
      end

      context "multiple query params" do
        it "sets the hash keys" do
          reader = Reader.new("?foo=bar&baz=qux").cursor
          map    = Map.build { query :foo; query :baz }
          data   = reader.read(map)
          expect(data).to eq(foo: "bar", baz: "qux")
        end
      end

      context "mixed parameter types" do
        it "reads path and query params" do
          reader = Reader.new("/foo?bar=baz").cursor
          map    = Map.build { path :foo; query :bar }
          data   = reader.read(map)
          expect(data).to eq(foo: "foo", bar: "baz")
        end
      end

      context "nested query params" do
        it "builds the nested structure" do
          reader = Reader.new("?bar.a=baz").cursor
          map    = Map.build { query :foo }
          nested = Map.build { query :bar }
          data   = reader.seek(0, Namespace.new("a")).read(nested)
          expect(data).to eq(bar: "baz")
        end
      end

      context "multiple nested maps" do
        it "builds the nested structure" do
          reader   = Reader.new("?foo=1&baz.bar=2&duck.qux=3").cursor
          bar_map  = Map.build { query :baz }
          qux_map  = Map.build { query :duck }
          top_map  = Map.build { query :foo }
          bar_data = reader.seek(top_map.path_count, Namespace.new("bar")).read(bar_map)
          qux_data = reader.seek(top_map.path_count, Namespace.new("qux")).read(qux_map)
          expect(bar_data).to eq(baz: "2")
          expect(qux_data).to eq(duck: "3")
        end
      end

      context "multiple nested path maps" do
        it "maps segments from the first nest" do
          reader  = Reader.new("/foo/bar?quux.n2=corge").cursor
          top     = Map.build { path :foo }
          n1      = Map.build { path :bar }
          n2      = Map.build { path :quux }
          n1_data = reader.seek(top.path_count, Namespace.new("bar")).read(n1)
          n2_data = reader.seek(top.path_count, Namespace.new("n2")).read(n2.off_route)
          expect(n1_data).to eq(bar: "bar")
          expect(n2_data).to eq(quux: "corge")
        end
      end

      context "extra keys" do
        it "reads only the declared keys" do
          reader = Reader.new("?foo=1&bar=2").cursor
          map    = Map.build { param :foo }
          data   = reader.read(map)
          expect(data).to eq(foo: "1")
        end
      end

      context "symmetry with writer" do
        context "nested query params" do
          it "deserializes data that was serialized by the writer" do
            data   = { foo: { bar: "baz" } }
            nested = Map.build { query :bar }
            writer = Writer.new
            writer.with_scope(Namespace.new("a")) do
              writer.write_state(nested, data[:foo])
            end
            reader = Reader.new(writer.to_s).cursor
            result = reader.seek(0, Namespace.new("a")).read(nested)
            expect(result).to eq(bar: "baz")
          end
        end

        context "multiple nested maps" do
          it "deserializes data that was serialized by the writer" do
            data    = { foo: { bar: "baz" }, qux: { duck: "corge" } }
            writer  = Writer.new
            foo_map = Map.build { query :bar }
            qux_map = Map.build { query :duck }
            writer.with_scope(Namespace.new("a")) { writer.write_state(foo_map, data[:foo]) }
            writer.with_scope(Namespace.new("b")) { writer.write_state(qux_map, data[:qux]) }
            reader     = Reader.new(writer.to_s).cursor
            top_map    = Map.build {}
            foo_result = reader.seek(top_map.path_count, Namespace.new("a")).read(foo_map)
            qux_result = reader.seek(top_map.path_count, Namespace.new("b")).read(qux_map)
            expect(foo_result).to eq(bar: "baz")
            expect(qux_result).to eq(duck: "corge")
          end
        end

        context "multiple nested path maps" do
          it "deserializes data that was serialized by the writer" do
            data    = { foo: { bar: "baz" }, qux: { kiln: "corge" } }
            writer  = Writer.new
            foo_map = Map.build { path :bar }
            qux_map = Map.build { path :kiln ; path "literal" }
            writer.with_scope(Namespace.new("a")) { writer.write_state foo_map, data[:foo] }
            writer.with_scope(Namespace.new("b")) { writer.write_state qux_map.off_route, data[:qux] }
            reader      = Reader.new(writer.to_s).cursor
            top_map     = Map.build {}
            foo_result  = reader.seek(top_map.path_count, Namespace.new("a")).read(foo_map)
            qux_result  = reader.seek(top_map.path_count, Namespace.new("b")).read(qux_map.off_route)
            expect(foo_result).to eq(bar: "baz")
            expect(qux_result).to eq(kiln: "corge")
          end
        end
      end
    end
  end
end
