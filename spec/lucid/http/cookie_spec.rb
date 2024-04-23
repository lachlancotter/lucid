module Lucid
  module HTTP
    describe Cookie do
      describe "#read" do
        context "valid cookie" do
          it "reads the session from the request cookie" do
            cookie_header = "lucid_cookie=eyJmb28iOiJiYXIifQ%3D%3D%0A"
            env           = { "HTTP_COOKIE" => cookie_header }
            request       = Rack::Request.new(env)
            cookie        = Cookie.new("lucid_cookie")
            cookie.read(request)
            expect(cookie).to be_a(Cookie)
            expect(cookie.to_h).to eq(foo: "bar")
            expect(cookie[:foo]).to eq("bar")
          end
        end

        context "invalid cookie" do
          it "raises an exception" do
            cookie_header = "lucid_cookie=eyJm"
            env           = { "HTTP_COOKIE" => cookie_header }
            request       = Rack::Request.new(env)
            cookie        = Cookie.new("lucid_cookie")
            expect {
              cookie.read(request)
            }.to raise_error(JSON::ParserError)
          end
        end
      end

      describe "#write" do
        it "writes the session to the response cookie" do
          cookie   = Cookie.new("lucid_cookie", foo: "bar")
          response = Rack::Response.new
          cookie.write(response)
          expect(response.headers["Set-Cookie"]).to eq("lucid_cookie=eyJmb28iOiJiYXIifQ%3D%3D%0A; path=/")
        end
      end

      describe "#[]=" do
        it "sets cookie data" do
          cookie       = Cookie.new("lucid_cookie")
          cookie[:foo] = "bar"
          expect(cookie[:foo]).to eq("bar")
          expect(cookie.to_h).to eq(foo: "bar")
        end
      end
    end
  end
end