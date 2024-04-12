module Lucid
  module HTTP
    describe ResponseAdaptor do
      describe "#send_delta" do
        context "without HTMX" do
          it "sends a redirect" do
            adaptor   = ResponseAdaptor.new(Rack::Response.new)
            component = double(href: "/foo")
            adaptor.send_delta(component, htmx: false)
            expect(adaptor.status).to eq(303)
            expect(adaptor.location).to eq("/foo")
          end
        end

        context "with HTMX" do
          it "sends the updated components" do
            adaptor   = ResponseAdaptor.new(Rack::Response.new)
            # render    = double(changes: "<html><body>foo</body></html>")
            # component = double(href: "/foo", render: render)
            component = Class.new(Component::Base) do
              path "foo"
              template do
                html {
                  body { text "foo" }
                }
              end
            end.new
            component.render.replace
            adaptor.send_delta(component, htmx: true)
            expect(adaptor.status).to eq(200)
            expect(adaptor.headers["HX-Push-Url"]).to eq("/foo")
            expect(adaptor.body).to eq("<html><body>foo</body></html>")
          end
        end
      end
    end
  end
end