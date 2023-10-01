require "ostruct"
require "lucid/route"
require "lucid/component"

module Lucid
  describe Route::Map do
    context "no rules" do
      it "returns the root path" do
        map   = Route::Map.new
        state = {}
        route = map.encode(state)
        expect(route.to_s).to eq("/")
      end
    end

    context "path rule" do
      it "returns rule field in the path" do
        map   = Route::Map.build do
          path :foo
        end
        state = { foo: "bar" }
        route = map.encode(state)
        expect(route.to_s).to eq("/bar")
      end
    end

    context "param rule" do
      it "returns rule field in the params" do
        map   = Route::Map.build do
          param :foo
        end
        state = { foo: "bar" }
        route = map.encode(state)
        expect(route.to_s).to eq("/?foo=bar")
      end
    end

    context "nested path rules" do
      it "builds a path from the nested fields" do
        state = { foo: "foo", bar: { baz: "baz" } }
        map   = Route::Map.build do
          path :foo
          nest :bar do
            Route::Map.build do
              path :baz
            end
          end
        end
        route = map.encode(state)
        expect(route.to_s).to eq("/foo/baz")
      end
    end

    context "nested param rules" do
      it "builds a path from the nested fields" do
        state = { foo: "foo", bar: { baz: "baz" } }
        map   = Route::Map.build do
          param :foo
          nest :bar do
            Route::Map.build do
              param :baz
            end
          end
        end
        route = map.encode(state)
        expect(route.to_s).to eq("/?foo=foo&bar[baz]=baz")
      end
    end

    context "multiple path components" do
      it "returns a route with multiple components" do
        map   = Route::Map.build do
          path :foo, :bar
          path :baz
        end
        state = { foo: "foo", bar: "bar", baz: "baz" }
        route = map.encode(state)
        expect(route.to_s).to eq("/foo/bar/baz")
      end
    end

    context "multiple params" do
      it "returns a route with multiple params" do
        map   = Route::Map.build do
          param :foo, :bar
          param :baz
        end
        state = { foo: "foo", bar: "bar", baz: "baz" }
        route = map.encode(state)
        expect(route.to_s).to eq("/?foo=foo&bar=bar&baz=baz")
      end
    end

    context "literal path components" do
      it "returns a route with literal components" do
        map   = Route::Map.build do
          path "lit", :foo
        end
        state = { foo: "foo" }
        route = map.encode(state)
        expect(route.to_s).to eq("/lit/foo")
      end
    end

    context "app_root" do
      context "base path" do
        it "prepends the path root" do
          map = Route::Map.build(app_root: "/root") do
            path "foo"
          end
          state = {}
          route = map.encode(state)
          expect(route.to_s).to eq("/root/foo")
        end
      end

      context "empty path" do
        it "prepends the path root" do
          map = Route::Map.build(app_root: "/") do
            path "foo"
          end
          state = {}
          route = map.encode(state)
          expect(route.to_s).to eq("/foo")
        end
      end
    end
  end

end