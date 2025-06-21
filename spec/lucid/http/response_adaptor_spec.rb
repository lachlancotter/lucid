module Lucid
  module HTTP
    describe ResponseAdaptor do
      describe "#send_state" do
        it "sends state" do
          adaptor   = ResponseAdaptor.new(Rack::Response.new, url_base: "/base/url")
          component = double(url: "/foo", render_full: "<html><body>foo</body></html>")
          adaptor.send_state(component)
          expect(adaptor.status).to eq(200)
          expect(adaptor.location).to eq("/base/url/foo")
          expect(adaptor.body).to eq("<html><body>foo</body></html>")
        end
      end
      
      describe "#send_delta" do
        context "without HTMX" do
          it "sends a redirect" do
            adaptor   = ResponseAdaptor.new(Rack::Response.new)
            component = double(url: "/foo")
            adaptor.send_delta(component, htmx: false)
            expect(adaptor.status).to eq(303)
            expect(adaptor.location).to eq("/foo")
          end

          context "with a URL base" do
            it "includes the URL base" do
              adaptor   = ResponseAdaptor.new(Rack::Response.new, url_base: "/base/url")
              component = double(url: "/foo")
              adaptor.send_delta(component, htmx: false)
              expect(adaptor.status).to eq(303)
              expect(adaptor.location).to eq("/base/url/foo")
            end
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

          context "with a URL base" do
            it "includes the URL base" do
              adaptor   = ResponseAdaptor.new(Rack::Response.new, url_base: "/base/url")
              component = Class.new(Component::Base) do
                route "foo"
                element(:html) { body { text "foo" } }
              end.new({})
              component.delta.replace
              adaptor.send_delta(component, htmx: true)
              expect(adaptor.status).to eq(200)
              expect(adaptor.headers["HX-Push-Url"]).to eq("/base/url/foo")
              expect(adaptor.body).to eq("<body>foo</body>")
            end
          end
        end
      end
    end
  end
end