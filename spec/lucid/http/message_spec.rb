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
              HTTP::Message.with_app_state(cycle) do
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
              HTTP::Message.with_app_state(cycle) do
                expect(message_class.url(foo: "bar")).to eq("/@/test/message?foo=bar")
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
              HTTP::Message.with_app_state(cycle) do
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
              HTTP::Message.with_app_state(cycle) do
                expect(message_class.url(foo: "bar")).to eq("/@/test/message")
              end
            end
          end
        end
      end

      # describe "#query_params" do
      #   context "HTML basic" do
      #     it "includes the current state" do
      #       base     = Class.new(Component::Base) { param :baz }
      #       message  = HTTP::Message.new(foo: "bar")
      #       env      = {
      #          "REQUEST_METHOD" => "GET",
      #          "PATH_INFO"      => "/",
      #          "QUERY_STRING"   => "baz=qux",
      #       }
      #       request  = RequestAdaptor.new(Rack::Request.new(env))
      #       response = double("response")
      #       config   = { app_root: "/", component: base }
      #       cycle    = build_cycle(request)
      #       HTTP::Message.with_app_state(cycle) do
      #         expect(message.query_params).to eq({ foo: "bar", state: { baz: "qux" } })
      #       end
      #     end
      #   end
      #
      #   context "HTMX" do
      #     it "omits the current state" do
      #       base     = Class.new(Component::Base) { param :baz }
      #       message  = HTTP::Message.new(foo: "bar")
      #       env      = {
      #          "REQUEST_METHOD"  => "GET",
      #          "PATH_INFO"       => "/",
      #          "QUERY_STRING"    => "baz=qux",
      #          "HTTP_HX_REQUEST" => "true"
      #       }
      #       request  = RequestAdaptor.new(Rack::Request.new(env))
      #       response = double("response")
      #       config   = { app_root: "/", component: base }
      #       cycle    = build_cycle(request)
      #       HTTP::Message.with_app_state(cycle) do
      #         expect(message.query_params).to eq({ foo: "bar" })
      #       end
      #     end
      #   end
      # end

    end
  end
end