module Lucid
  class App
    describe Cycle do
      let(:container) do
        App::Container.new({
           component_class: component_class,
           handler_class:   handler_class,
           request:         request,
           response:        response
        }, env)
      end
      let(:request) { Rack::Request.new(env) }
      let(:response) { Rack::Response.new }
      let(:cycle) { Cycle.new(container) }

      class TestLink < Lucid::Link

      end

      let(:component_class) do
        Class.new(Lucid::Component::Base) do
          param :foo, Types.string.default("bar".freeze)
          element do
            h1 { text "Hello, World!" }
            p { link_to TestLink.new, "Link" }
          end
        end
      end
      let(:handler_class) { Lucid::Handler }

      describe "#state" do
        let(:env) do
          {
             "REQUEST_METHOD" => "GET",
             "PATH_INFO"      => "/",
             "QUERY_STRING"   => "baz=qux",
          }
        end

        it "renders the component to the response" do
          cycle.state
          expect(response.body).to include("Hello, World!")
        end

        context "basic request" do
          it "propagates state" do
            cycle.state
            expect(response.body).to include('href="/@/lucid/app/test-link?state%5Bfoo%5D=bar"')
          end
        end

        context "HTMX request" do
          let(:env) do
            {
               "REQUEST_METHOD"  => "GET",
               "PATH_INFO"       => "/",
               "QUERY_STRING"    => "baz=qux",
               "HTTP_HX_REQUEST" => "true"
            }
          end
          it "omits state" do
            cycle.state
            expect(response.body).to include('href="/@/lucid/app/test-link"')
            expect(response.body).not_to include('state%5Bfoo%5D=bar')
          end
        end
      end

      describe "#link" do
        let(:component_class) do
          Class.new(Lucid::Component::Base) do
            param :foo, Types.string.default("bar".freeze)
            to TestLink, foo: "baz"
            element do |foo|
              h1 { text "Linking Component" }
              p { text "param: #{foo}" }
            end
          end
        end

        context "basic request" do
          let(:env) do
            {
               "REQUEST_METHOD" => "GET",
               "PATH_INFO"      => HTTP::URL.new(TestLink, {}).path,
               "QUERY_STRING"   => HTTP::URL.new(TestLink, {}).query_string,
            }
          end
          it "applies the link and redirects to the new state" do
            cycle.link
            expect(response.location).to eq("/?foo=baz")
            expect(response.status).to eq(303)
          end
        end

        context "HTMX" do
          let(:env) do
            {
               "REQUEST_METHOD"      => "GET",
               "PATH_INFO"           => HTTP::URL.new(TestLink, {}).path,
               "QUERY_STRING"        => HTTP::URL.new(TestLink, {}).query_string,
               "HTTP_HX_REQUEST"     => "true",
               "HTTP_HX_CURRENT_URL" => "/"
            }
          end
          it "applies the link and renders the new state" do
            cycle.link
            expect(response.status).to eq(200)
            expect(response.headers['hx-push-url']).to eq("/?foo=baz")
            expect(response.body).to include("param: baz")
          end
        end
      end

      describe "#command" do
        class TestCommand < Lucid::Command

        end

        class TestEvent < Lucid::Event

        end

        let(:component_class) do
          Class.new(Lucid::Component::Base) do
            param :foo, Types.string.default("bar".freeze)
            on(TestEvent) { update(foo: "baz") }
            element do |foo|
              h1 { text "Linking Component" }
              p { text "param: #{foo}" }
            end
          end
        end

        let(:handler_class) do
          Class.new(Lucid::Handler) do
            perform(TestCommand) { publish TestEvent.new }
          end
        end

        context "basic request" do
          let(:env) do
            {
               "REQUEST_METHOD" => "GET",
               "PATH_INFO"      => HTTP::URL.new(TestCommand, {}).path,
               "QUERY_STRING"   => HTTP::URL.new(TestCommand, {}).query_string,
            }
          end
          it "dispatches the command and redirects to the new state" do
            cycle.command
            expect(response.location).to eq("/?foo=baz")
            expect(response.status).to eq(303)
          end
        end

        context "HTMX" do
          let(:env) do
            {
               "REQUEST_METHOD"      => "GET",
               "PATH_INFO"           => HTTP::URL.new(TestCommand, {}).path,
               "QUERY_STRING"        => HTTP::URL.new(TestCommand, {}).query_string,
               "HTTP_HX_REQUEST"     => "true",
               "HTTP_HX_CURRENT_URL" => "/"
            }
          end
          it "applies the link and renders the new state" do
            cycle.command
            expect(response.headers['hx-push-url']).to eq("/?foo=baz")
            expect(response.status).to eq(200)
            expect(response.body).to include("param: baz")
          end
        end
      end

    end
  end
end