module Lucid
  module State
    describe Store do
      describe ".from_url" do
        it "creates an empty store from nil" do
          store = Store.from_url(nil)
          expect(store.to_url).to eq("/")
        end

        it "creates an empty store from empty string" do
          store = Store.from_url("")
          expect(store.to_url).to eq("/")
        end

        it "parses a simple path" do
          store = Store.from_url("/users/123")
          expect(store.get_segment(0)).to eq("users")
          expect(store.get_segment(1)).to eq("123")
        end

        it "parses a path with query parameters" do
          store = Store.from_url("/search?q=test&page=2")
          expect(store.get_segment(0)).to eq("search")
          expect(store.get_param("q")).to eq("test")
          expect(store.get_param("page")).to eq("2")
        end

        it "handles multiple slashes correctly" do
          store = Store.from_url("///users//123///")
          expect(store.get_segment(0)).to eq("users")
          expect(store.get_segment(1)).to eq("123")
          expect(store.get_segment(2)).to be_nil
        end

        it "handles query parameters without values" do
          store = Store.from_url("/search?q=")
          expect(store.get_param("q")).to eq("")
        end

        it "handles query parameters with equals in value" do
          store = Store.from_url("/search?formula=a=b")
          expect(store.get_param("formula")).to eq("a=b")
        end

        it "ignores empty query parameters" do
          store = Store.from_url("/search?q=test&&page=2")
          expect(store.get_param("q")).to eq("test")
          expect(store.get_param("page")).to eq("2")
        end

        it "decodes URL-encoded path segments" do
          store = Store.from_url("/users/john%20doe/profile")
          expect(store.get_segment(0)).to eq("users")
          expect(store.get_segment(1)).to eq("john doe")
          expect(store.get_segment(2)).to eq("profile")
        end

        it "decodes URL-encoded query parameters" do
          store = Store.from_url("/search?q=hello%20world&tag=ruby%2Brails")
          expect(store.get_param("q")).to eq("hello world")
          expect(store.get_param("tag")).to eq("ruby+rails")
        end

        it "handles special characters in URL" do
          store = Store.from_url("/api/search?query=%E2%9C%93&filter=a%26b")
          expect(store.get_param("query")).to eq("✓")
          expect(store.get_param("filter")).to eq("a&b")
        end

        it "parses dash as nil segment" do
          store = Store.from_url("/users/-/profile")
          expect(store.get_segment(0)).to eq("users")
          expect(store.get_segment(1)).to be_nil
          expect(store.get_segment(2)).to eq("profile")
        end

        it "handles multiple nil segments" do
          store = Store.from_url("/api/-/-/resource")
          expect(store.get_segment(0)).to eq("api")
          expect(store.get_segment(1)).to be_nil
          expect(store.get_segment(2)).to be_nil
          expect(store.get_segment(3)).to eq("resource")
        end
      end

      describe "#initialize" do
        it "creates a store with default empty values" do
          store = Store.new
          expect(store.to_url).to eq("/")
        end

        it "creates a store with path segments" do
          store = Store.new(["users", "123"])
          expect(store.get_segment(0)).to eq("users")
          expect(store.get_segment(1)).to eq("123")
        end

        it "creates a store with path and params" do
          store = Store.new(["search"], {"q" => "test", "page" => "2"})
          expect(store.get_segment(0)).to eq("search")
          expect(store.get_param("q")).to eq("test")
          expect(store.get_param("page")).to eq("2")
        end

        it "raises error if path is not an Array" do
          expect { Store.new("not_an_array") }.to raise_error(Dry::Types::CoercionError)
          expect { Store.new(123) }.to raise_error(Dry::Types::CoercionError)
        end

        it "raises error if params is not a Hash" do
          expect { Store.new([], "not_a_hash") }.to raise_error(Dry::Types::CoercionError)
          expect { Store.new([], []) }.to raise_error(Dry::Types::CoercionError)
        end
      end

      describe "#to_url" do
        it "returns root path for empty store" do
          store = Store.new
          expect(store.to_url).to eq("/")
        end

        it "converts path segments to URL" do
          store = Store.new(["users", "123", "profile"])
          expect(store.to_url).to eq("/users/123/profile")
        end

        it "includes query parameters" do
          store = Store.new(["search"], {"q" => "test", "page" => "2"})
          url = store.to_url
          expect(url).to start_with("/search?")
          expect(url).to include("q=test")
          expect(url).to include("page=2")
        end

        it "handles path with no segments but with params" do
          store = Store.new([], {"q" => "test"})
          expect(store.to_url).to eq("/?q=test")
        end

        it "encodes special characters in path segments" do
          store = Store.new(["users", "john doe", "profile"])
          expect(store.to_url).to eq("/users/john+doe/profile")
        end

        it "encodes special characters in query parameters" do
          store = Store.new(["search"], {"q" => "hello world", "tag" => "ruby&rails"})
          url = store.to_url
          expect(url).to include("q=hello+world")
          expect(url).to include("tag=ruby%26rails")
        end

        it "encodes unicode characters" do
          store = Store.new(["api"], {"emoji" => "✓"})
          url = store.to_url
          expect(url).to include("emoji=%E2%9C%93")
        end

        it "encodes nil segments as dash" do
          store = Store.new(["users", nil, "profile"])
          expect(store.to_url).to eq("/users/-/profile")
        end

        it "handles multiple nil segments" do
          store = Store.new(["api", nil, nil, "resource"])
          expect(store.to_url).to eq("/api/-/-/resource")
        end

        it "handles all nil segments" do
          store = Store.new([nil, nil, nil])
          expect(store.to_url).to eq("/")
        end

        it "drops trailing nil segments" do
          store = Store.new(["users", "123", nil])
          expect(store.to_url).to eq("/users/123")
        end

        it "drops multiple trailing nil segments" do
          store = Store.new(["users", "123", nil, nil, nil])
          expect(store.to_url).to eq("/users/123")
        end

        it "keeps nil segments that precede non-nil segments" do
          store = Store.new(["users", nil, "profile", nil])
          expect(store.to_url).to eq("/users/-/profile")
        end

        it "keeps leading nil segments if followed by non-nil" do
          store = Store.new([nil, nil, "resource"])
          expect(store.to_url).to eq("/-/-/resource")
        end
      end

      describe "#get_segment" do
        it "returns nil for non-existent segment" do
          store = Store.new(["users"])
          expect(store.get_segment(1)).to be_nil
        end

        it "returns the segment at given index" do
          store = Store.new(["users", "123", "profile"])
          expect(store.get_segment(0)).to eq("users")
          expect(store.get_segment(1)).to eq("123")
          expect(store.get_segment(2)).to eq("profile")
        end

        it "supports negative indices" do
          store = Store.new(["users", "123", "profile"])
          expect(store.get_segment(-1)).to eq("profile")
          expect(store.get_segment(-2)).to eq("123")
        end
      end

      describe "#set_segment" do
        it "sets a segment at given index" do
          store = Store.new(["users", "123"])
          store.set_segment(1, "456")
          expect(store.get_segment(1)).to eq("456")
        end

        it "allows setting segments to nil" do
          store = Store.new(["users", "123", "profile"])
          store.set_segment(1, nil)
          expect(store.get_segment(1)).to be_nil
          expect(store.to_url).to eq("/users/-/profile")
        end

        it "drops trailing nil when set" do
          store = Store.new(["users", "123", "profile"])
          store.set_segment(2, nil)
          expect(store.get_segment(2)).to be_nil
          expect(store.to_url).to eq("/users/123")
        end

        it "expands array if index is beyond current size" do
          store = Store.new(["users"])
          store.set_segment(2, "profile")
          expect(store.get_segment(2)).to eq("profile")
          expect(store.get_segment(1)).to be_nil
        end

        it "supports negative indices" do
          store = Store.new(["users", "123", "profile"])
          store.set_segment(-1, "settings")
          expect(store.get_segment(2)).to eq("settings")
        end

        it "mutates the store" do
          store = Store.new(["users", "123"])
          store.set_segment(0, "posts")
          expect(store.to_url).to eq("/posts/123")
        end
      end

      describe "#get_param" do
        it "returns nil for non-existent parameter" do
          store = Store.new([], {"q" => "test"})
          expect(store.get_param("page")).to be_nil
        end

        it "returns the parameter value" do
          store = Store.new([], {"q" => "test", "page" => "2"})
          expect(store.get_param("q")).to eq("test")
          expect(store.get_param("page")).to eq("2")
        end
      end

      describe "#set_param" do
        it "sets a parameter value" do
          store = Store.new
          store.set_param("q", "test")
          expect(store.get_param("q")).to eq("test")
        end

        it "overwrites existing parameter" do
          store = Store.new([], {"q" => "old"})
          store.set_param("q", "new")
          expect(store.get_param("q")).to eq("new")
        end

        it "mutates the store" do
          store = Store.new(["search"])
          store.set_param("q", "test")
          expect(store.to_url).to eq("/search?q=test")
        end
      end

      describe "round-trip conversion" do
        it "preserves data through from_url and to_url" do
          original_url = "/users/123/profile?tab=posts&sort=date"
          store = Store.from_url(original_url)
          reconstructed_url = store.to_url
          
          expect(store.get_segment(0)).to eq("users")
          expect(store.get_segment(1)).to eq("123")
          expect(store.get_segment(2)).to eq("profile")
          expect(store.get_param("tab")).to eq("posts")
          expect(store.get_param("sort")).to eq("date")
          
          # Note: query parameter order may vary, so check components
          expect(reconstructed_url).to start_with("/users/123/profile?")
          expect(reconstructed_url).to include("tab=posts")
          expect(reconstructed_url).to include("sort=date")
        end

        it "preserves nil segments through round-trip" do
          original_url = "/users/-/profile"
          store = Store.from_url(original_url)
          
          expect(store.get_segment(1)).to be_nil
          expect(store.to_url).to eq(original_url)
        end
      end

      describe "mutability" do
        it "allows manipulation of path and params" do
          store = Store.from_url("/users/123")
          
          # Modify path
          store.set_segment(0, "posts")
          store.set_segment(1, "456")
          
          # Add params
          store.set_param("page", "1")
          store.set_param("limit", "10")
          
          url = store.to_url
          expect(url).to start_with("/posts/456?")
          expect(url).to include("page=1")
          expect(url).to include("limit=10")
        end
      end
    end
  end
end
