require "lucid/http/request_adaptor"

module Lucid
  module HTTP
    describe RequestAdaptor do

      describe "#state_reader" do
        context "state URL" do
          it "reads from the fullpath" do
            env     = {
               "REQUEST_METHOD" => "GET",
               "PATH_INFO"      => "/store/guitars-basses",
               "QUERY_STRING"   => "",
               "rack.input"     => StringIO.new("")
            }
            adaptor = RequestAdaptor.new(Rack::Request.new(env))
            reader  = adaptor.state_reader(app_root: "/")
            map     = State::Map.new.tap do |map|
              map.path(:step)
              map.path(:category_slug)
            end
            expect(reader.read(map)).to eq({ step: "store", category_slug: "guitars-basses" })
          end
        end

        context "message URL" do
          context "basic request" do
            it "reads from the state param" do
              env     = {
                 "REQUEST_METHOD" => "GET",
                 "PATH_INFO"      => "/@/shopping/product/list",
                 "QUERY_STRING"   => "category_slug=guitars-basses&state[step]=store",
                 "rack.input"     => StringIO.new("")
              }
              adaptor = RequestAdaptor.new(Rack::Request.new(env))
              reader  = adaptor.state_reader(app_root: "/")
              map     = State::Map.new.tap do |map|
                map.path(:step)
                map.path(:category_slug)
              end
              expect(reader.read(map)).to eq({ step: "store" })
            end
          end

          context "HTMX request" do
            it "reads from the current URL" do
              env     = {
                 "REQUEST_METHOD"      => "GET",
                 "PATH_INFO"           => "/@/shopping/product/list",
                 "QUERY_STRING"        => "category_slug=guitars-basses",
                 "rack.input"          => StringIO.new(""),
                 "HTTP_HX_REQUEST"     => "true",
                 "HTTP_HX_CURRENT_URL" => "http://test.com/store/pianos-keyboards"
              }
              adaptor = RequestAdaptor.new(Rack::Request.new(env))
              reader  = adaptor.state_reader(app_root: "/")
              map     = State::Map.new.tap do |map|
                map.path(:step)
                map.path(:category_slug)
              end
              expect(reader.read(map)).to eq({ step: "store", category_slug: "pianos-keyboards" })
            end
          end
        end
      end

      describe ".normalize_path" do
        context "empty path" do
          it "eq /" do
            expect(RequestAdaptor.normalize_path("/", "/")).to eq("/")
          end
        end

        context "with app root" do
          it "removes the app root" do
            expect(RequestAdaptor.normalize_path("/a/b/c/d", "/a/b/c")).to eq("/d")
          end
        end

        context "with hostname" do
          it "removes the hostname" do
            expect(RequestAdaptor.normalize_path("http://test.com/a/b/c/d", "/a/b/c")).to eq("/d")
          end
        end

        context "with params" do
          it "includes the params" do
            expect(RequestAdaptor.normalize_path("/a/b/c/d?foo=bar", "/a/b/c")).to eq("/d?foo=bar")
          end
        end
      end

      describe ".htmx?" do
        context "without an HTMX header" do
          it "is false" do
            request = Rack::Request.new({})
            adaptor = RequestAdaptor.new(request)
            expect(adaptor.htmx?).to be(false)
          end
        end

        context "with an HTMX header" do
          it "is true" do
            request = Rack::Request.new("HTTP_HX_REQUEST" => "true")
            adaptor = RequestAdaptor.new(request)
            expect(adaptor.htmx?).to be(true)
          end
        end
      end

      describe "#raw_params" do
        it "decodes GET params" do
          get_params = { "id" => "1", "state" => { "foo" => "bar" } }
          request    = Rack::Request.new("REQUEST_METHOD" => "GET", "QUERY_STRING" => Rack::Utils.build_nested_query(get_params), "rack.input" => StringIO.new(""))
          params     = RequestAdaptor.new(request).raw_params
          expect(params).to eq(get_params)
        end

        it "decodes POST params" do
          post_params = { "id" => "1", "state" => { "foo" => "bar" } }
          request     = Rack::Request.new("REQUEST_METHOD" => "POST", "rack.input" => StringIO.new(Rack::Utils.build_nested_query(post_params)))
          params      = RequestAdaptor.new(request).raw_params
          expect(params).to eq({ "id" => "1", "state" => { "foo" => "bar" } })
        end

        it "decodes mixed params" do
          get_params  = { "id" => "1" }
          post_params = { "state" => { "baz" => "qux" } }
          request     = Rack::Request.new("REQUEST_METHOD" => "POST", "rack.input" => StringIO.new(Rack::Utils.build_nested_query(post_params)), "QUERY_STRING" => Rack::Utils.build_nested_query(get_params))
          params      = RequestAdaptor.new(request).raw_params
          expect(params).to eq({ "id" => "1", "state" => { "baz" => "qux" } })
        end
      end

    end
  end
end