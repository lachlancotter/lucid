module Lucid
  module State
    describe HashReader do
      context "empty query" do
        it "returns an empty hash" do
          reader = HashReader.new({})
          map    = Map.build {}
          data   = reader.read(map)
          expect(data).to eq({})
        end
      end

      context "single path component" do
        it "sets the hash key" do
          reader = HashReader.new({ foo: "foo" })
          map    = Map.build { path :foo }
          data   = reader.read(map)
          expect(data).to eq(foo: "foo")
        end
      end

      context "multiple path components" do
        it "sets the hash keys" do
          reader = HashReader.new({ foo: "foo", bar: "bar" })
          map    = Map.build { path :foo, :bar }
          data   = reader.read(map)
          expect(data).to eq(foo: "foo", bar: "bar")
        end
      end

      context "literal path components" do
        it "skips literals" do
          reader = HashReader.new(foo: "foo")
          map    = Map.build { path "lit", :foo }
          data   = reader.read(map)
          expect(data).to eq(foo: "foo")
        end
      end

      context "single query param" do
        it "sets the hash key" do
          reader = HashReader.new(foo: "bar")
          map    = Map.build { query :foo }
          data   = reader.read(map)
          expect(data).to eq(foo: "bar")
        end
      end

      context "multiple query params" do
        it "sets the hash keys" do
          reader = HashReader.new(foo: "bar", baz: "qux")
          map    = Map.build { query :foo, :baz }
          data   = reader.read(map)
          expect(data).to eq(foo: "bar", baz: "qux")
        end
      end

      context "mixed parameter types" do
        it "reads path and query params" do
          reader = HashReader.new(foo: "foo", bar: "baz")
          map    = Map.build { path :foo; query :bar }
          data   = reader.read(map)
          expect(data).to eq(foo: "foo", bar: "baz")
        end
      end

      context "nested query params" do
        it "builds the nested structure" do
          reader = HashReader.new(foo: { bar: "baz" })
          map    = Map.build { query :foo }
          nested = Map.build { query :bar }
          data   = reader.seek(0, :foo).read(nested)
          expect(data).to eq(bar: "baz")
        end
      end

      context "multiple nested maps" do
        it "builds the nested structure" do
          reader   = HashReader.new({ foo: "1", bar: { baz: "2" }, qux: { duck: "3" } })
          bar_map  = Map.build { query :baz }
          qux_map  = Map.build { query :duck }
          top_map  = Map.build { query :foo }
          bar_data = reader.seek(top_map.path_count, :bar).read(bar_map)
          qux_data = reader.seek(top_map.path_count, :qux).read(qux_map)
          expect(bar_data).to eq(baz: "2")
          expect(qux_data).to eq(duck: "3")
        end
      end

      context "extra keys" do
        it "reads only the declared keys" do
          reader = HashReader.new(foo: "1", bar: "2")
          map    = Map.build { param :foo }
          data   = reader.read(map)
          expect(data).to eq(foo: "1")
        end
      end
    end
  end
end
