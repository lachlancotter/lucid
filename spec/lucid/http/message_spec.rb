module Lucid
  module HTTP
    describe Message do

      describe ".url" do
        let(:response) { double("response") }
        let(:base) { Class.new(Component::Base) { param :baz } }
        let(:config) { { app_root: "/", component: base } }

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
            it "includes the current state" do
              request = RequestAdaptor.new(
                 Rack::Request.new({
                    "REQUEST_METHOD" => "GET",
                    "PATH_INFO"      => "/",
                    "QUERY_STRING"   => "baz=qux",
                 })
              )
              cycle   = App::Cycle.new(request, response, config)
              HTTP::Message.with_app_state(cycle) do
                expect(message_class.url(foo: "bar")).to eq("/@/test/message?foo=bar&state[baz]=qux")
              end
            end
          end

          context "HTMX" do
            it "omits the current state" do
              request = RequestAdaptor.new(
                 Rack::Request.new({
                    "REQUEST_METHOD"  => "GET",
                    "PATH_INFO"       => "/",
                    "QUERY_STRING"    => "baz=qux",
                    "HTTP_HX_REQUEST" => "true"
                 })
              )
              cycle   = App::Cycle.new(request, response, config)
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
            it "includes the current state and omits message params" do
              request = RequestAdaptor.new(
                 Rack::Request.new({
                    "REQUEST_METHOD" => "GET",
                    "PATH_INFO"      => "/",
                    "QUERY_STRING"   => "baz=qux",
                 })
              )
              cycle   = App::Cycle.new(request, response, config)
              HTTP::Message.with_app_state(cycle) do
                expect(message_class.url(foo: "bar")).to eq("/@/test/message?state[baz]=qux")
              end
            end
          end

          context "HTMX" do
            it "omits the current state" do
              request = RequestAdaptor.new(
                 Rack::Request.new({
                    "REQUEST_METHOD"  => "GET",
                    "PATH_INFO"       => "/",
                    "QUERY_STRING"    => "baz=qux",
                    "HTTP_HX_REQUEST" => "true"
                 })
              )
              cycle   = App::Cycle.new(request, response, config)
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
      #       cycle    = App::Cycle.new(request, response, config)
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
      #       cycle    = App::Cycle.new(request, response, config)
      #       HTTP::Message.with_app_state(cycle) do
      #         expect(message.query_params).to eq({ foo: "bar" })
      #       end
      #     end
      #   end
      # end

      describe ".decode_name" do
        context "no namespace" do
          it "raises an exception" do
            url     = "/not/a/message"
            request = double("request", fullpath: url)
            expect { HTTP::Message.decode_name(request) }.to raise_error(HTTP::Message::InvalidName)
          end
        end

        context "no message name" do
          it "raises an exception" do
            url     = "/@/"
            request = double("request", fullpath: url)
            expect { HTTP::Message.decode_name(request) }.to raise_error(HTTP::Message::InvalidName)
          end
        end

        context "no params" do
          it "decodes the message name" do
            url     = "/@/shopping/product/list"
            request = double("request", fullpath: url)
            name    = HTTP::Message.decode_name(request)
            expect(name).to eq("Shopping::Product::List")
          end
        end

        context "app root" do
          it "decodes the message name" do
            url     = "/app_root/@/shopping/product/list"
            request = double("request", fullpath: url)
            name    = HTTP::Message.decode_name(request)
            expect(name).to eq("Shopping::Product::List")
          end
        end

        context "full message name and params" do
          it "decodes message names from URLs" do
            url     = "/@/shopping/product/list?category_slug=guitars-basses&state[step]=store"
            request = double("request", fullpath: url)
            name    = HTTP::Message.decode_name(request)
            expect(name).to eq("Shopping::Product::List")
          end
        end
      end

      describe ".decode_params" do
        it "decodes GET params" do
          request = double("request", GET: { "id" => "1", "state" => { "foo" => "bar" } }, POST: {})
          params  = HTTP::Message.decode_params(request)
          expect(params).to eq({ "id" => "1", "state" => { "foo" => "bar" } })
        end

        it "decodes POST params" do
          request = double("request", GET: {}, POST: { "id" => "1", "state" => { "foo" => "bar" } })
          params  = HTTP::Message.decode_params(request)
          expect(params).to eq({ "id" => "1", "state" => { "foo" => "bar" } })
        end

        it "decodes mixed params" do
          request = double("request", GET: { "id" => "1" }, POST: { "state" => { "baz" => "qux" } })
          params  = HTTP::Message.decode_params(request)
          expect(params).to eq({ "id" => "1", "state" => { "baz" => "qux" } })
        end
      end
    end
  end
end