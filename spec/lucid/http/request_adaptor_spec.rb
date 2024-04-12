require "lucid/http/request_adaptor"

module Lucid
  module HTTP
    describe RequestAdaptor do
      describe "#state_reader" do
        context "state URL" do
          it "reads from the fullpath" do
            url     = "/store/guitars-basses"
            adaptor = RequestAdaptor.new(double(fullpath: url))
            reader  = adaptor.state_reader(app_root: "/")
            map     = State::Map.new.tap do |map|
              map.path(:step, 0)
              map.path(:category_slug, 1)
            end
            expect(reader.read(map)).to eq({ step: "store", category_slug: "guitars-basses" })
          end
        end

        context "message URL" do
          it "reads from the state param" do
            url        = "/@/shopping/product/list?category_slug=guitars-basses&state[step]=store"
            get_params = { "category_slug" => "guitars-basses", "state" => { "step" => "store" } }
            adaptor    = RequestAdaptor.new(double(fullpath: url, GET: get_params, POST: {}))
            reader     = adaptor.state_reader(app_root: "/")
            map        = State::Map.new.tap do |map|
              map.path(:step, 0)
              map.path(:category_slug, 1)
            end
            expect(reader.read(map)).to eq({ step: "store" })
          end
        end
      end

      describe "#href" do
        context "/" do
          it "eq /" do
            adaptor = RequestAdaptor.new(double(fullpath: "/"))
            expect(adaptor.href("/")).to eq("/")
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
    end
  end
end