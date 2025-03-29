module Lucid
  module HTTP
    describe ResponseAdaptor do
      describe "#send_delta" do
        context "without HTMX" do
          it "sends a redirect" do
            adaptor   = ResponseAdaptor.new(Rack::Response.new)
            component = double(url: "/foo")
            adaptor.send_delta(component, htmx: false)
            expect(adaptor.status).to eq(303)
            expect(adaptor.location).to eq("/foo")
          end
        end

        context "with HTMX" do
          it "sends the updated components" do
            adaptor = ResponseAdaptor.new(Rack::Response.new)
            component = Class.new(Component::Base) do
              route "foo"
              element(:html) { body { text "foo" } }
            end.new({})
            component.delta.replace
            adaptor.send_delta(component, htmx: true)
            expect(adaptor.status).to eq(200)
            expect(adaptor.headers["HX-Push-Url"]).to eq("/foo")
            expect(adaptor.body).to eq("<body>foo</body>")
          end
        end
      end
    end
  end
end