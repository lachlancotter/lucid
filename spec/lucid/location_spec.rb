require "ostruct"
require "lucid/location"

module Lucid
  describe Location do
    describe "+" do
      it "returns a href for the message" do
        map     = Location::Map.build { param :foo }
        state   = Location.new({ foo: "bar" }, map)
        message = Link.new(baz: "qux")
        href    = state + message
        expect(href.to_s).to eq("/?foo=bar&msg=Lucid%3A%3ALink&Lucid%3A%3ALink[baz]=qux")
      end
    end
  end

  describe Location::Map do
    describe "#encode" do
      context "no rules" do
        it "returns the root path" do
          map   = Location::Map.new
          state = {}
          route = map.encode(state)
          expect(route.to_s).to eq("/")
        end
      end

      context "path rule" do
        it "returns rule field in the path" do
          map   = Location::Map.build do
            path :foo
          end
          state = { foo: "bar" }
          route = map.encode(state)
          expect(route.to_s).to eq("/bar")
        end
      end

      context "param rule" do
        it "returns rule field in the params" do
          map   = Location::Map.build do
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
          map   = Location::Map.build do
            path :foo
            nest :bar do
              Location::Map.build do
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
          map   = Location::Map.build do
            param :foo
            nest :bar do
              Location::Map.build do
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
          map   = Location::Map.build do
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
          map   = Location::Map.build do
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
          map   = Location::Map.build do
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
            map   = Location::Map.build(app_root: "/root") do
              path "foo"
            end
            state = {}
            route = map.encode(state)
            expect(route.to_s).to eq("/root/foo")
          end
        end

        context "empty path" do
          it "prepends the path root" do
            map   = Location::Map.build(app_root: "/") do
              path "foo"
            end
            state = {}
            route = map.encode(state)
            expect(route.to_s).to eq("/foo")
          end
        end
      end
    end

    describe "#decode" do
      context "empty query" do
        it "returns an empty state" do
          query = "/"
          map   = Location::Map.build { path :foo }
          state = map.decode(query)
          expect(state).to eq({})
        end
      end

      context "single path component" do
        it "extracts state" do
          query = "/top-level"
          map   = Location::Map.build { path :foo }
          state = map.decode(query)
          expect(state).to eq({ foo: "top-level" })
        end
      end

      context "multiple path components" do
        it "extracts state" do
          query = "/top-level/second-level"
          map   = Location::Map.build { path :foo, :bar }
          state = map.decode(query)
          expect(state).to eq({ foo: "top-level", bar: "second-level" })
        end
      end

      context "nested maps" do
        it "extracts state" do
          query = "/top-level/second-level"
          map   = Location::Map.build do
            path :foo
            nest :bar do
              Location::Map.build do
                path :baz
              end
            end
          end
          state = map.decode(query)
          expect(state).to eq({ foo: "top-level", bar: { baz: "second-level" } })
        end
      end

      context "literal path components" do
        it "extracts state" do
          query = "/lit/foo"
          map   = Location::Map.build do
            path "lit", :foo
          end
          state = map.decode(query)
          expect(state).to eq({ foo: "foo" })
        end
      end

      context "single query param" do
        it "extracts state" do
          query = "/?foo=bar"
          map   = Location::Map.build { param :foo }
          state = map.decode(query)
          expect(state).to eq({ foo: "bar" })
        end
      end

      context "multiple query params" do
        it "extracts state" do
          query = "/?foo=bar&baz=qux"
          map   = Location::Map.build { param :foo, :baz }
          state = map.decode(query)
          expect(state).to eq({ foo: "bar", baz: "qux" })
        end
      end

      context "nested query params" do
        it "extracts state" do
          query = "/?foo[bar]=baz"
          map   = Location::Map.build do
            nest :foo do
              Location::Map.build do
                param :bar
              end
            end
          end
          state = map.decode(query)
          expect(state).to eq({ foo: { bar: "baz" } })
        end
      end

      context "with app root" do
        it "extracts state" do
          query = "/root/foo"
          map   = Location::Map.build(app_root: "/root") do
            path :foo
          end
          state = map.decode(query)
          expect(state).to eq({ foo: "foo" })
        end
      end
    end
  end
end