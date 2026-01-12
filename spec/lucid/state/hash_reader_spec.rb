module Lucid
  module State
    describe HashStore do
      context "empty query" do
        it "returns an empty hash" do
          reader = HashStore.new({}).scoped
          map    = Map.build {}
          data   = reader.read(map)
          expect(data).to eq({})
        end
      end

      context "single path component" do
        it "sets the hash key" do
          reader = HashStore.new({ foo: "foo" }).scoped
          map    = Map.build { path :foo }
          data   = reader.read(map)
          expect(data).to eq(foo: "foo")
        end
      end

      context "multiple path components" do
        it "sets the hash keys" do
          reader = HashStore.new({ foo: "foo", bar: "bar" }).scoped
          map    = Map.build { path :foo; path :bar }
          data   = reader.read(map)
          expect(data).to eq(foo: "foo", bar: "bar")
        end
      end

      context "literal path components" do
        it "skips literals" do
          reader = HashStore.new(foo: "foo").scoped
          map    = Map.build { path "lit"; path :foo }
          data   = reader.read(map)
          expect(data).to eq(foo: "foo")
        end
      end

      context "single query param" do
        it "sets the hash key" do
          reader = HashStore.new(foo: "bar").scoped
          map    = Map.build { query :foo }
          data   = reader.read(map)
          expect(data).to eq(foo: "bar")
        end
      end

      context "multiple query params" do
        it "sets the hash keys" do
          reader = HashStore.new(foo: "bar", baz: "qux").scoped
          map    = Map.build { query :foo; query :baz }
          data   = reader.read(map)
          expect(data).to eq(foo: "bar", baz: "qux")
        end
      end

      context "mixed parameter types" do
        it "reads path and query params" do
          reader = HashStore.new(foo: "foo", bar: "baz").scoped
          map    = Map.build { path :foo; query :bar }
          data   = reader.read(map)
          expect(data).to eq(foo: "foo", bar: "baz")
        end
      end

      context "nested query params" do
        it "builds the nested structure" do
          reader = HashStore.new(foo: { bar: "baz" })
          nested = Map.build { query :bar }
          data   = reader.scoped.descend(0, 0).read(nested)
          expect(data).to eq(bar: "baz")
        end
      end

      context "multiple nested maps" do
        it "builds the nested structure" do
          reader   = HashStore.new({ foo: "1", bar: { baz: "2" }, qux: { duck: "3" } }).scoped
          bar_map  = Map.build { query :baz }
          qux_map  = Map.build { query :duck }
          top_map  = Map.build { query :foo }
          bar_data = reader.descend(top_map.path_count, 1).read(bar_map)
          qux_data = reader.descend(top_map.path_count, 2).read(qux_map)
          expect(bar_data).to eq(baz: "2")
          expect(qux_data).to eq(duck: "3")
        end
      end

      context "extra keys" do
        it "reads only the declared keys" do
          reader = HashStore.new(foo: "1", bar: "2").scoped
          map    = Map.build { param :foo }
          data   = reader.read(map)
          expect(data).to eq(foo: "1")
        end
      end

      describe HashStore::CoordinateEnumerator do
        it "enumerates flat hash with empty coordinates" do
          hash = { foo: "a", bar: "b" }
          enumerator = HashStore::CoordinateEnumerator.new(hash)
          results = enumerator.to_a

          expect(results).to contain_exactly(
            [[], :foo, "a"],
            [[], :bar, "b"]
          )
        end

        it "enumerates nested hash with coordinate indices" do
          hash = {
            root_key: "root_value",
            nested: {
              child_key: "child_value"
            }
          }
          enumerator = HashStore::CoordinateEnumerator.new(hash)
          results = enumerator.to_a

          expect(results).to contain_exactly(
            [[], :root_key, "root_value"],
            [[1], :child_key, "child_value"]
          )
        end

        it "assigns coordinates based on key order" do
          hash = {
            first: "a",
            second: { nested: "b" },
            third: "c"
          }
          enumerator = HashStore::CoordinateEnumerator.new(hash)
          results = enumerator.to_a

          expect(results).to contain_exactly(
            [[], :first, "a"],
            [[1], :nested, "b"],
            [[], :third, "c"]
          )
        end

        it "handles deeply nested hashes" do
          hash = {
            level1: {
              level2: {
                level3: "deep"
              }
            }
          }
          enumerator = HashStore::CoordinateEnumerator.new(hash)
          results = enumerator.to_a

          expect(results).to eq([
            [[0, 0], :level3, "deep"]
          ])
        end

        it "handles multiple nested children" do
          hash = {
            first: {
              child_a: "a",
              child_b: "b"
            },
            second: {
              child_c: "c"
            }
          }
          enumerator = HashStore::CoordinateEnumerator.new(hash)
          results = enumerator.to_a

          expect(results).to contain_exactly(
            [[0], :child_a, "a"],
            [[0], :child_b, "b"],
            [[1], :child_c, "c"]
          )
        end

        it "handles complex nested structure" do
          hash = {
            root1: "value1",
            root2: {
              nested1: "value2",
              nested2: {
                deep: "value3"
              }
            },
            root3: "value4"
          }
          enumerator = HashStore::CoordinateEnumerator.new(hash)
          results = enumerator.to_a

          expect(results).to contain_exactly(
            [[], :root1, "value1"],
            [[1], :nested1, "value2"],
            [[1, 1], :deep, "value3"],
            [[], :root3, "value4"]
          )
        end

        it "works as an enumerable" do
          hash = { foo: "a", bar: "b" }
          enumerator = HashStore::CoordinateEnumerator.new(hash)
          
          keys = enumerator.map { |(coordinate, key, value)| key }
          expect(keys).to contain_exactly(:foo, :bar)
        end
      end
    end
  end
end
