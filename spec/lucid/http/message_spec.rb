module Lucid
  module HTTP
    describe Message do

      describe ".url" do
        let(:response) { double("response") }
        let(:component_class) { Class.new(Component::Base) { param :baz } }
        let(:container_class) { Class.new(App::Container) }
        let(:config) { { component_class: component_class } }
        let(:container) { container_class.new(config, env) }

        def build_cycle (request)
          App::Cycle.new(request, response, container)
        end

        context "GET request" do
          let(:message_class) do
            Class.new(Message) do
              def self.message_name
                "test/message"
              end

              def self.http_method
                Message::GET
              end
            end
          end

          context "HTML basic" do
            let(:env) do
              {
                 "REQUEST_METHOD" => "GET",
                 "PATH_INFO"      => "/",
                 "QUERY_STRING"   => "baz=qux",
              }
            end
            it "includes the current state" do
              request = RequestAdaptor.new(Rack::Request.new(env))
              cycle   = build_cycle(request)
              HTTP::Message.with_state(cycle.send(:state_for_messages)) do
                expect(message_class.url(foo: "bar")).to eq("/@/test/message?foo=bar&state[baz]=qux")
              end
            end
          end

          context "HTMX" do
            let(:env) do
              {
                 "REQUEST_METHOD"  => "GET",
                 "PATH_INFO"       => "/",
                 "QUERY_STRING"    => "baz=qux",
                 "HTTP_HX_REQUEST" => "true"
              }
            end
            it "omits the current state" do
              request = RequestAdaptor.new(Rack::Request.new(env))
              cycle   = build_cycle(request)
              HTTP::Message.with_state(cycle.send(:state_for_messages)) do
                expect(message_class.url(foo: "bar")).to eq("/@/test/message?foo=bar")
              end
            end
          end

          context "base url" do
            let(:env) do
              {
                 "REQUEST_METHOD" => "GET",
                 "PATH_INFO"      => "/",
                 "QUERY_STRING"   => "baz=qux",
              }
            end
            it "includes the current state" do
              request = RequestAdaptor.new(Rack::Request.new(env))
              cycle   = build_cycle(request)
              HTTP::Message.with_url_base("/base/url") do
                HTTP::Message.with_state(cycle.send(:state_for_messages)) do
                  expect(message_class.url(foo: "bar")).to eq("/base/url/@/test/message?foo=bar&state[baz]=qux")
                end
              end
            end
          end
        end

        context "POST request" do
          let(:message_class) do
            Class.new(HTTP::Message) do
              def self.message_name
                "test/message"
              end

              def self.http_method
                HTTP::Message::POST
              end
            end
          end

          context "HTML basic" do
            let(:env) do
              {
                 "REQUEST_METHOD" => "GET",
                 "PATH_INFO"      => "/",
                 "QUERY_STRING"   => "baz=qux",
              }
            end
            it "includes the current state and omits message params" do
              request = RequestAdaptor.new(Rack::Request.new(env))
              cycle   = build_cycle(request)
              HTTP::Message.with_state(cycle.send(:state_for_messages)) do
                expect(message_class.url(foo: "bar")).to eq("/@/test/message?state[baz]=qux")
              end
            end
          end

          context "HTMX" do
            let(:env) do
              {
                 "REQUEST_METHOD"  => "GET",
                 "PATH_INFO"       => "/",
                 "QUERY_STRING"    => "baz=qux",
                 "HTTP_HX_REQUEST" => "true"
              }
            end
            it "omits the current state" do
              request = RequestAdaptor.new(Rack::Request.new(env))
              cycle   = build_cycle(request)
              HTTP::Message.with_state(cycle.send(:state_for_messages)) do
                expect(message_class.url(foo: "bar")).to eq("/@/test/message")
              end
            end
          end
        end
      end

    end
  end
end