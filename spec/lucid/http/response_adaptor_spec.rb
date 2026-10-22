module Lucid
  module HTTP
    describe ResponseAdaptor do
      describe "#send_state" do
        it "sends state" do
          adaptor   = ResponseAdaptor.new(Rack::Response.new, url_base: "/base/url")
          component = double(url: "/foo", render: "<html><body>foo</body></html>")
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
            expect(adaptor.body).to eq("<title>Untitled</title>\n<body>foo</body>")
          end

          it "sends the title resolved from the updated navigation state" do
            navigation = Class.new(Link)
            component_class = Class.new(Component::Base) do
              param :section, Types.string.default("sessions".freeze)
              title { |section| "Satori: #{section.capitalize}" }
              to navigation, section: "clients"
              element { |section| text section }
            end
            component = component_class.new({}, navigation.new)
            adaptor = ResponseAdaptor.new(Rack::Response.new)

            adaptor.send_delta(component, htmx: true)

            expect(adaptor.body).to eq("<title>Satori: Clients</title>\nclients")
            expect(adaptor.headers["HX-Retarget"]).to eq("#root")
            expect(adaptor.headers["HX-Reswap"]).to eq("outerHTML")
          end

          it "sends the root title composed with the nested route title" do
            child_class = Class.new(Component::Base) do
              param :section, Types.string
              title { |section| section.capitalize }
            end
            component = Class.new(Component::Base) do
              route "/base", nest: :child
              nest(:child) { child_class }
              title { "Satori: #{nested_title}" }
            end.new({ child: { section: "clients" } })
            component.child.delta.replace
            adaptor = ResponseAdaptor.new(Rack::Response.new)

            adaptor.send_delta(component, htmx: true)

            expect(adaptor.body).to start_with("<title>Satori: Clients</title>\n")
          end

          it "sends the page title before SVG titles in updated components" do
            component = Class.new(Component::Base) do
              title { "Page title" }
              element { svg { title { text "Icon title" } } }
            end.new({})
            component.delta.replace
            adaptor = ResponseAdaptor.new(Rack::Response.new)

            adaptor.send_delta(component, htmx: true)

            expect(adaptor.body).to start_with("<title>Page title</title>\n")
            expect(adaptor.body).to include("<svg><title>Icon title</title></svg>")
          end

          it "HTML-escapes the title" do
            component = Class.new(Component::Base) do
              title { 'Clients & </title><script>alert("hello")</script>' }
            end.new({})
            component.delta.replace
            adaptor = ResponseAdaptor.new(Rack::Response.new)

            adaptor.send_delta(component, htmx: true)

            expect(adaptor.body).to start_with(
              "<title>Clients &amp; &lt;/title&gt;&lt;script&gt;alert(&quot;hello&quot;)&lt;/script&gt;</title>"
            )
          end

          it "sends title updates even when no components change" do
            navigation = Class.new(Link)
            component = Class.new(Component::Base) do
              route "/foo"
              param :section, Types.string.default("sessions".freeze)
              title { |section| "Satori: #{section.capitalize}" }
              to navigation, section: "clients"
              element { text "Unchanged content" }
            end.new({}, navigation.new)
            adaptor = ResponseAdaptor.new(Rack::Response.new, url_base: "/base/url")

            expect(component.changes).to be_empty
            adaptor.send_delta(component, htmx: true)

            expect(adaptor.status).to eq(200)
            expect(adaptor.body).to eq("<title>Satori: Clients</title>")
            expect(adaptor.headers["HX-Push-Url"]).to eq("/base/url/foo?section=clients")
            expect(adaptor.headers["HX-Reswap"]).to eq("none")
            expect(adaptor.headers["HX-Retarget"]).to be_nil
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
              expect(adaptor.body).to eq("<title>Untitled</title>\n<body>foo</body>")
            end
          end
        end
      end

      describe "#send_external_redirect" do
        context "without HTMX" do
          it "sends a redirect response" do
            adaptor = ResponseAdaptor.new(Rack::Response.new, url_base: "/base/url")

            adaptor.send_external_redirect("https://example.com/checkout", htmx: false)

            expect(adaptor.status).to eq(303)
            expect(adaptor.location).to eq("https://example.com/checkout")
          end
        end

        context "with HTMX" do
          it "sends an HX-Redirect response header" do
            adaptor = ResponseAdaptor.new(Rack::Response.new, url_base: "/base/url")

            adaptor.send_external_redirect("https://example.com/checkout", htmx: true)

            expect(adaptor.status).to eq(200)
            expect(adaptor.headers["HX-Redirect"]).to eq("https://example.com/checkout")
          end
        end
      end
    end
  end
end
