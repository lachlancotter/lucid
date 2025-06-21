module Lucid
  module HTTP
    describe Endpoint do
      describe "#relative" do
        context "empty path" do
          it "eq /" do
            expect(Endpoint.relative("/", base: "/")).to eq("/")
          end
        end

        context "with app root" do
          it "removes the app root" do
            expect(Endpoint.relative("/a/b/c/d", base: "/a/b/c")).to eq("/d")
          end
        end

        context "path matches app root" do
          it "eq /" do
            expect(Endpoint.relative("/a", base: "/a")).to eq("/")
          end
        end

        context "with hostname" do
          it "removes the hostname" do
            expect(Endpoint.relative("http://test.com/a/b/c/d", base: "/a/b/c")).to eq("/d")
          end
        end

        context "with params" do
          it "includes the params" do
            expect(Endpoint.relative("/a/b/c/d?foo=bar", base: "/a/b/c")).to eq("/d?foo=bar")
          end
        end
      end

    end
  end
end